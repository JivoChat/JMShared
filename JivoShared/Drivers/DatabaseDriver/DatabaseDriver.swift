//
//  DatabaseDriver.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import JMTimelineKit

public enum DatabaseDriverWriting {
    case anyThread
    case backgroundThread
}

public protocol IDatabaseDriver: class {    
    func parallel() -> IDatabaseDriver
    func refresh() -> IDatabaseDriver

    func reference<OT: Object>(to object: OT?, behavior: ModelRefBehavior) -> ModelRef<OT>
    func resolve<OT: Object>(ref: ThreadSafeReference<OT>) -> OT?
    
    func read(_ block: (IDatabaseContext) -> Void)
    func readwrite(_ block: (IDatabaseContext) -> Void)

    func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT]
    func object<OT, VT>(_ type: OT.Type, primaryKey: VT) -> OT?
    func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT?
    
    func subscribe<OT>(_ type: OT.Type, options: DatabaseRequestOptions?, returnEntireCollectionOnUpdate: Bool, callback: @escaping ([OT]) -> Void) -> DatabaseListener
    func subscribe<OT>(object: OT, callback: @escaping (OT?) -> Void) -> DatabaseListener
    func unsubscribe(_ token: DatabaseSubscriberToken)
    
    func simpleRemove<OT>(objects: [OT]) -> Bool
    func customRemove<OT>(objects: [OT], recursive: Bool)
    func removeAll()
}

fileprivate struct DatabaseToken {
    public let realmToken: NotificationToken
    public let notificationToken: NSObjectProtocol?
}

open class DatabaseDriver: IDatabaseDriver {
    private let writing: DatabaseDriverWriting
    private let fileURL: URL?
    private let memoryIdentifier: String
    private let timelineCache: JMTimelineCache

    private var readonlyContext: DatabaseContext?
    private var readwriteContext: DatabaseContext?
    private var tokens = [DatabaseSubscriberToken: DatabaseToken]()
    
    private var recentThread: Thread?
    private var recentRunLoop: RunLoop?
    
    public let localizer: Localizer
    
    public init(writing: DatabaseDriverWriting, fileURL: URL?, memoryIdentifier: String, timelineCache: JMTimelineCache, localizer: Localizer) {
        self.writing = writing
        self.fileURL = fileURL
        self.memoryIdentifier = memoryIdentifier
        self.timelineCache = timelineCache
        self.localizer = localizer
        
        print("{database-driver} ::init @file-url[\(fileURL)]")
    }
    
    public func parallel() -> IDatabaseDriver {
        return DatabaseDriver(
            writing: writing,
            fileURL: fileURL,
            memoryIdentifier: memoryIdentifier,
            timelineCache: timelineCache,
            localizer: localizer)
    }
    
    public func refresh() -> IDatabaseDriver {
        context.realm.refresh()
        return self
    }

    public func reference<OT: Object>(to object: OT?, behavior: ModelRefBehavior) -> ModelRef<OT> {
        return ModelRef(databaseDriver: self, value: object, behavior: behavior)
    }
    
    public func resolve<OT: Object>(ref: ThreadSafeReference<OT>) -> OT? {
        return context.realm.resolve(ref)
    }
    
    public func read(_ block: (IDatabaseContext) -> Void) {
        block(context)
    }
    
    public func readwrite(_ block: (IDatabaseContext) -> Void) {
        switch writing {
        case .backgroundThread where Thread.isMainThread:
            assertionFailure("Please use background thread for modifications")
        case .backgroundThread:
            break
        case .anyThread:
            break
        }
        
        context.performTransaction { ctx in
            block(ctx)
        }
    }
    
    public func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT] {
        return context.objects(type, options: options)
    }
    
    public func object<OT, VT>(_ type: OT.Type, primaryKey: VT) -> OT? {
        return context.object(type, primaryKey: primaryKey)
    }
    
    public func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT? {
        return context.object(type, mainKey: mainKey)
    }
    
    public func subscribe<OT>(_ type: OT.Type, options: DatabaseRequestOptions?, returnEntireCollectionOnUpdate: Bool, callback: @escaping ([OT]) -> Void) -> DatabaseListener {
        let objects = context.getObjects(type as! Object.Type, options: options)
        let token = objects.observe { change in
            switch change {
            case .initial(let results): callback(Array(results) as! [OT])
            case let .update(results, _, insertions, modifications):
                if returnEntireCollectionOnUpdate {
                    callback(Array(results) as! [OT])
                } else {
                    let modificatedResults = results
                        .enumerated()
                        .filter { modifications.contains($0.offset) || insertions.contains($0.offset) }
                        .map { $0.element }
                    callback(Array(modificatedResults) as! [OT])
                }
            case .error: break
            }
        }
        
        let internalToken = UUID()
        
        tokens[internalToken] = DatabaseToken(
            realmToken: token,
            notificationToken: options?.notificationName.map { name in
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: nil,
                    using: { _ in callback(Array(objects) as! [OT]) }
                )
            }
        )
        
        return DatabaseListener(token: internalToken, databaseDriver: self)
    }
    
    public func subscribe<OT>(object: OT, callback: @escaping (OT?) -> Void) -> DatabaseListener {
        let token = (object as! Object).observe { change in
            switch change {
            case .change: callback(object)
            case .deleted: callback(nil)
            case .error: break
            }
        }
        
        let internalToken = UUID()
        
        tokens[internalToken] = DatabaseToken(
            realmToken: token,
            notificationToken: nil
        )
        
        return DatabaseListener(token: internalToken, databaseDriver: self)
    }
    
    public func unsubscribe(_ token: DatabaseSubscriberToken) {
        if let item = tokens[token] {
            if let observer = item.notificationToken {
                NotificationCenter.default.removeObserver(observer)
            }
            
            item.realmToken.invalidate()
            tokens.removeValue(forKey: token)
        }
    }
    
    public func simpleRemove<OT>(objects: [OT]) -> Bool {
        return context.performTransaction { ctx in
            ctx.simpleRemove(objects: objects)
        }
    }
    
    public func customRemove<OT>(objects: [OT], recursive: Bool) {
        context.performTransaction { ctx in
            ctx.customRemove(objects: objects, recursive: recursive)
        }
    }
    
    public func removeAll() {
        context.performTransaction { ctx in
            ctx.removeAll()
        }
    }
    
    private var context: DatabaseContext {
        if Thread.isMainThread {
            if let object = readonlyContext {
                return object
            }
            else {
                let object = buildContext()
                readonlyContext = object
                return object
            }
        }
        else {
            if let object = readwriteContext {
                assert(Thread.current === recentThread)
                assert(RunLoop.current === recentRunLoop)
                return object
            }
            else {
                let object = buildContext()
                readwriteContext = object
                recentThread = Thread.current
                recentRunLoop = RunLoop.current
                return object
            }
        }
    }
    
    private func buildContext() -> DatabaseContext {
        let config = generateConfig()
        if let realm = try? Realm(configuration: config) {
            return DatabaseContext(realm: realm, timelineCache: timelineCache, localizer: localizer)
        }
        else {
            abort()
        }
    }
    
    private func generateConfig() -> Realm.Configuration {
        if let url = fileURL {
            return Realm.Configuration(fileURL: url, inMemoryIdentifier: nil, deleteRealmIfMigrationNeeded: true)
        }
        else {
            return Realm.Configuration(inMemoryIdentifier: memoryIdentifier)
        }
    }
}
