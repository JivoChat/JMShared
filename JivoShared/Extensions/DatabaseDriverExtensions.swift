//
//  DatabaseContextExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension IDatabaseDriver {
    func subscribe<OT>(_ type: OT.Type, options: DatabaseRequestOptions?, returnEntireCollectionOnUpdate: Bool = true, callback: @escaping ([OT]) -> Void) -> DatabaseListener {
        return subscribe(type, options: options, returnEntireCollectionOnUpdate: returnEntireCollectionOnUpdate, callback: callback)
    }
    
    func insert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.insert(of: type, with: changes)
        }
        
        return result
    }
    
    func upsert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange) -> OT? {
        var result: OT?
        
        readwrite { context in
            result = context.upsert(of: type, with: change)
        }

        return result
    }
    
    func upsert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.upsert(of: type, with: changes)
        }
        
        return result
    }
    
    func update<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange) -> OT? {
        var result: OT?
        
        readwrite { context in
            result = context.update(of: type, with: change)
        }
        
        return result
    }
    
    func replaceAll<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.replaceAll(of: type, with: changes)
        }
        
        return result
    }
    
    func chatWithID(_ ID: Int) -> JVChat? {
        var chat: JVChat?
        
        read { context in
            chat = context.chatWithID(ID)
        }
        
        return chat
    }

    func client(for clientID: Int, needsDefault: Bool) -> JVClient? {
        var client: JVClient?

        read { context in
            client = context.client(for: clientID, needsDefault: needsDefault)
        }

        return client
    }
    
    func chatForMessage(_ message: JVMessage, evenArchived: Bool) -> JVChat? {
        if let client = message.client {
            return chat(for: client.ID, evenArchived: evenArchived)
        }
        else {
            return chatWithID(message.chatID)
        }
    }

    func agents(withMe: Bool) -> [JVAgent] {
        var agents = [JVAgent]()
        
        let predicate: NSPredicate
        if withMe {
            predicate = NSPredicate(format: "_email != ''")
        }
        else {
            predicate = NSPredicate(format: "_email != '' AND _session == nil")
        }
        
        read { context in
            agents = context.objects(
                JVAgent.self,
                options: DatabaseRequestOptions(
                    filter: predicate
                )
            )
        }
        
        return agents
    }
    
    func agent(for agentID: Int, provideDefault: Bool) -> JVAgent? {
        var agent: JVAgent?
        
        read { context in
            agent = context.agent(for: agentID, provideDefault: false)
        }
        
        if agent == nil, provideDefault {
            readwrite { context in
                agent = context.agent(for: agentID, provideDefault: true)
            }
        }
        
        return agent
    }
    
    func chat(for clientID: Int, evenArchived: Bool) -> JVChat? {
        var chat: JVChat?
        
        read { context in
            guard let client = context.client(for: clientID, needsDefault: false) else { return }
            chat = context.chatsWithClient(client, includeArchived: evenArchived).first
        }
        
        return chat
    }
    
    func message(for UUID: String) -> JVMessage? {
        var message: JVMessage?
        
        read { context in
            message = context.messageWithUUID(UUID)
        }
        
        return message
    }
}

public extension IDatabaseContext {
    func find<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?) -> OT? {
        if let change = change, change.isValid {
            if let integerKey = change.integerKey {
                return object(OT.self, mainKey: integerKey)
            }
            else if let stringKey = change.stringKey {
                return object(OT.self, mainKey: stringKey)
            }
            else if change.primaryValue != 0 {
                return object(OT.self, primaryKey: change.primaryValue)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }

    func insert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> OT? {
        guard let change = change else {
            return nil
        }

        guard change.isValid || !validOnly else {
            return nil
        }

        let obj = OT.init()
        obj.apply(inside: self, with: change)
        add([obj])

        return obj
    }
    
    func insert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?, validOnly: Bool = false) -> [OT] {
        guard let changes = changes else {
            return []
        }

        return changes.compactMap {
            insert(of: type, with: $0, validOnly: validOnly)
        }
    }
    
    func upsert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> OT? {
        let (obj, _) = upsertCallback(of: type, with: change, validOnly: validOnly)
        return obj
    }
    
    func upsertCallback<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> (OT?, Bool) {
        var newlyAdded = false
        
        if let change = change, change.isValid {
            let obj: OT
            if let integerKey = change.integerKey {
                if let o = object(OT.self, mainKey: integerKey) {
                    obj = o
                    newlyAdded = false
                }
                else {
                    obj = OT()
                    newlyAdded = true
                }
            }
            else if let stringKey = change.stringKey {
                if let o = object(OT.self, mainKey: stringKey) {
                    obj = o
                    newlyAdded = false
                }
                else {
                    obj = OT()
                    newlyAdded = true
                }
            }
            else if change.primaryValue != 0 {
                if let o = object(OT.self, primaryKey: change.primaryValue) {
                    obj = o
                    newlyAdded = false
                }
                else {
                    obj = OT()
                    newlyAdded = true
                }
            }
            else {
                obj = OT()
                newlyAdded = true
            }
            
            obj.apply(inside: self, with: change)
            
            if obj.realm == nil {
                add([obj])
            }
            
            return (obj, newlyAdded)
        }
        else {
            return (nil, false)
        }
    }
    
    func upsert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?) -> [OT] {
        if let changes = changes {
            return changes.compactMap { upsert(of: type, with: $0) }
        }
        else {
            return []
        }
    }
    
    func upsert<OT: JVBaseModel>(_ model: OT?, with change: BaseModelChange?) -> OT? {
        guard let change = change else {
            return model
        }
        
        if let model = model {
            model.apply(inside: self, with: change)
            return model
        }
        else {
            return insert(of: OT.self, with: change)
        }
    }
    
    func update<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?) -> OT? {
        guard let change = change else {
            return nil
        }
        
        let obj: OT?
        if let integerKey = change.integerKey {
            if let foundObject = object(OT.self, mainKey: integerKey) {
                obj = foundObject
            }
            else if let stringKey = change.stringKey {
                obj = object(OT.self, mainKey: stringKey)
            }
            else {
                obj = nil
            }
        }
        else if let stringKey = change.stringKey {
            if let foundObject = object(OT.self, mainKey: stringKey) {
                obj = foundObject
            }
            else if let integerKey = change.integerKey {
                obj = object(OT.self, mainKey: integerKey)
            }
            else {
                obj = nil
            }
        }
        else if change.primaryValue != 0 {
            obj = object(OT.self, primaryKey: change.primaryValue)
        }
        else {
            obj = nil
        }
        
        if let obj = obj, obj.isValid {
            obj.apply(inside: self, with: change)
        }
        
        return obj
    }
    
    func replaceAll<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        objects(type, options: nil).forEach { $0.recursiveDelete(context: self) }
        return upsert(of: type, with: changes)
    }
    
    func models<MT: JVBaseModel>(for IDs: [Int]) -> [MT] {
        return IDs.compactMap { self.object(MT.self, primaryKey: $0) }
    }
    
    func agent(for agentID: Int, provideDefault: Bool) -> JVAgent? {
        if let value = object(JVAgent.self, primaryKey: agentID) {
            return value
        }
        else if provideDefault {
            return upsert(of: JVAgent.self, with: AgentGeneralChange(placeholderID: agentID))
        }
        else {
            return nil
        }
    }
    
    func department(for departmentID: Int) -> JVDepartment? {
        if let value = object(JVDepartment.self, primaryKey: departmentID) {
            return value
        }
        else {
            return nil
        }
    }
    
    func client(for clientID: Int, needsDefault: Bool) -> JVClient? {
        if let value = object(JVClient.self, primaryKey: clientID) {
            return value
        }
        else if needsDefault {
            return upsert(of: JVClient.self, with: ClientGeneralChange(clientID: clientID))
        }
        else {
            return nil
        }
    }
    
    func clientID(for chatID: Int) -> Int? {
        if let value = valueForKey(chatID) {
            return value
        }
        else {
            return chatWithID(chatID)?.client?.ID
        }
    }
    
    func chatWithID(_ ID: Int) -> JVChat? {
        return object(JVChat.self, primaryKey: ID)
    }
    
    func messageWithUUID(_ UUID: String) -> JVMessage? {
        return object(JVMessage.self, mainKey: DatabaseContextMainKey(key: "_UUID", value: UUID))
    }
    
    func chatsWithClient(_ client: JVClient, includeArchived: Bool) -> [JVChat] {
        let predicate: NSPredicate
        if includeArchived {
            predicate = NSPredicate(format: "_client._ID == \(client.ID)")
        }
        else {
            predicate = NSPredicate(format: "_client._ID == \(client.ID) && _isArchived == false")
        }

        return objects(
            JVChat.self,
            options: DatabaseRequestOptions(
                filter: predicate,
                sortBy: [],
                notificationName: nil
            )
        )
    }
    
    func createMessage(with change: BaseModelChange) -> JVMessage {
        let message = JVMessage(localizer: localizer)
        message.apply(inside: self, with: change)
        add([message])
        return message
    }
    
    func messageWithCallID(_ callID: String?) -> JVMessage? {
        guard let callID = callID else { return nil }

        let filter = NSPredicate(format: "_body._callID == %@", callID)
        let options = DatabaseRequestOptions(filter: filter)
        return objects(JVMessage.self, options: options).last
    }
    
    func removeChat(_ chat: JVChat, cleanup: Bool) {
        if cleanup, let client = chat.client, client.isValid {
            let messages = objects(
                JVMessage.self,
                options: DatabaseRequestOptions(
                    filter: NSPredicate(format: "_clientID == %d", client.ID),
                    sortBy: []
                )
            )
            
            customRemove(objects: messages, recursive: true)
        }
        
        customRemove(objects: [chat], recursive: true)
    }

    func removeMessages(uuids: [String]) {
        guard !uuids.isEmpty else { return }

        let messages = objects(
            JVMessage.self,
            options: DatabaseRequestOptions(
                filter: NSPredicate(format: "_UUID in %@", uuids)
            )
        )

        customRemove(objects: messages, recursive: true)
    }
}
