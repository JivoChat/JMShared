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
    
    public func insert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.insert(of: type, with: changes)
        }
        
        return result
    }
    
    public func upsert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange) -> OT? {
        var result: OT?
        
        readwrite { context in
            result = context.upsert(of: type, with: change)
        }

        return result
    }
    
    public func upsert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.upsert(of: type, with: changes)
        }
        
        return result
    }
    
    public func update<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange) -> OT? {
        var result: OT?
        
        readwrite { context in
            result = context.update(of: type, with: change)
        }
        
        return result
    }
    
    public func replaceAll<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        var result = [OT]()
        
        readwrite { context in
            result = context.replaceAll(of: type, with: changes)
        }
        
        return result
    }
    
    public func chatWithID(_ ID: Int) -> Chat? {
        var chat: Chat?
        
        read { context in
            chat = context.chatWithID(ID)
        }
        
        return chat
    }

    public func client(for clientID: Int, needsDefault: Bool) -> Client? {
        var client: Client?

        read { context in
            client = context.client(for: clientID, needsDefault: needsDefault)
        }

        return client
    }
    
    public func chatForMessage(_ message: JVMessage, evenArchived: Bool) -> Chat? {
        if let client = message.client {
            return chat(for: client.ID, evenArchived: evenArchived)
        }
        else {
            return chatWithID(message.chatID)
        }
    }

    public func agents(withMe: Bool) -> [JVAgent] {
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
    
    public func agent(for agentID: Int, provideDefault: Bool) -> JVAgent? {
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
    
    public func chat(for clientID: Int, evenArchived: Bool) -> Chat? {
        var chat: Chat?
        
        read { context in
            guard let client = context.client(for: clientID, needsDefault: false) else { return }
            chat = context.chatsWithClient(client, includeArchived: evenArchived).first
        }
        
        return chat
    }
    
    public func message(for UUID: String) -> JVMessage? {
        var message: JVMessage?
        
        read { context in
            message = context.messageWithUUID(UUID)
        }
        
        return message
    }
}

public extension IDatabaseContext {
    public func find<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?) -> OT? {
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

    public func insert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> OT? {
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
    
    public func insert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?, validOnly: Bool = false) -> [OT] {
        guard let changes = changes else {
            return []
        }

        return changes.compactMap {
            insert(of: type, with: $0, validOnly: validOnly)
        }
    }
    
    public func upsert<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> OT? {
        let (obj, _) = upsertCallback(of: type, with: change, validOnly: validOnly)
        return obj
    }
    
    public func upsertCallback<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?, validOnly: Bool = false) -> (OT?, Bool) {
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
    
    public func upsert<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]?) -> [OT] {
        if let changes = changes {
            return changes.compactMap { upsert(of: type, with: $0) }
        }
        else {
            return []
        }
    }
    
    public func upsert<OT: JVBaseModel>(_ model: OT?, with change: BaseModelChange?) -> OT? {
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
    
    public func update<OT: JVBaseModel>(of type: OT.Type, with change: BaseModelChange?) -> OT? {
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
    
    public func replaceAll<OT: JVBaseModel>(of type: OT.Type, with changes: [BaseModelChange]) -> [OT] {
        objects(type, options: nil).forEach { $0.recursiveDelete(context: self) }
        return upsert(of: type, with: changes)
    }
    
    public func models<MT: JVBaseModel>(for IDs: [Int]) -> [MT] {
        return IDs.compactMap { self.object(MT.self, primaryKey: $0) }
    }
    
    public func agent(for agentID: Int, provideDefault: Bool) -> JVAgent? {
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
    
    public func client(for clientID: Int, needsDefault: Bool) -> Client? {
        if let value = object(Client.self, primaryKey: clientID) {
            return value
        }
        else if needsDefault {
            return upsert(of: Client.self, with: ClientGeneralChange(clientID: clientID))
        }
        else {
            return nil
        }
    }
    
    public func clientID(for chatID: Int) -> Int? {
        if let value = valueForKey(chatID) {
            return value
        }
        else {
            return chatWithID(chatID)?.client?.ID
        }
    }
    
    public func chatWithID(_ ID: Int) -> Chat? {
        return object(Chat.self, primaryKey: ID)
    }
    
    public func messageWithUUID(_ UUID: String) -> JVMessage? {
        return object(JVMessage.self, mainKey: DatabaseContextMainKey(key: "_UUID", value: UUID))
    }
    
    public func chatsWithClient(_ client: Client, includeArchived: Bool) -> [Chat] {
        let predicate: NSPredicate
        if includeArchived {
            predicate = NSPredicate(format: "_client._ID == \(client.ID)")
        }
        else {
            predicate = NSPredicate(format: "_client._ID == \(client.ID) && _isArchived == false")
        }

        return objects(
            Chat.self,
            options: DatabaseRequestOptions(
                filter: predicate,
                sortBy: [],
                notificationName: nil
            )
        )
    }
    
    public func createMessage(with change: BaseModelChange) -> JVMessage {
        let message = JVMessage(localizer: localizer)
        message.apply(inside: self, with: change)
        add([message])
        return message
    }
    
    public func messageWithCallID(_ callID: String?) -> JVMessage? {
        guard let callID = callID else { return nil }

        let filter = NSPredicate(format: "_body._callID == %@", callID)
        let options = DatabaseRequestOptions(filter: filter)
        return objects(JVMessage.self, options: options).last
    }
    
    public func removeChat(_ chat: Chat, cleanup: Bool) {
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

    public func removeMessages(uuids: [String]) {
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
