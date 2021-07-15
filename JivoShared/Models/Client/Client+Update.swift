//
//  Client+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension Client {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _guestID = c.guestID.valuable ?? _guestID
            _chatID = c.chatID ?? _chatID
            _channelID = c.channelID
            _channelName = c.channelName ?? _channelName
            _channel = context.object(Channel.self, primaryKey: c.channelID)
            _displayName = c.displayName ?? String()
            _avatarLink = c.avatarURL ?? _avatarLink
            _comment = c.comment
            _visitsNumber = c.visitsNumber ?? _visitsNumber
            _navigatesNumber = c.navigatesNumber ?? _navigatesNumber
            _activeSession = context.upsert(_activeSession, with: c.activeSession)
            _isOnline = c.connectionLost?.inverted() ?? _isOnline
            _hasStartup = c.hasStartup
            _isBlocked = c.isBlocked
            
            if c.phoneByAgent == c.phoneByClient {
                _phoneByClient = nil
                _phoneByAgent = c.phoneByAgent.map(simplifyPhoneNumber)
            }
            else {
                _phoneByClient = c.phoneByClient.map(simplifyPhoneNumber)
                _phoneByAgent = c.phoneByAgent.map(simplifyPhoneNumber)
            }
            
            if c.emailByAgent == c.emailByClient {
                _emailByClient = nil
                _emailByAgent = c.emailByAgent
            }
            else {
                _emailByClient = c.emailByClient
                _emailByAgent = c.emailByAgent
            }
            
            switch c.assignedAgentID {
            case .none: break
            case 0?: _assignedAgent = nil
            case .some(let agentID): _assignedAgent = context.agent(for: agentID, provideDefault: true)
            }
            
            if let integration = c.integration ?? _integration?.valuable {
                _integration = integration
                _integrationLink = c.socialLinks[integration]
            }
            else if let integration = c.socialLinks.keys.first {
                _integration = integration
                _integrationLink = c.socialLinks[integration]
            }

            _task = context.upsert(of: Task.self, with: c.task) ?? _task
            
            if let customData = c.customData {
                _customData.set(context.insert(of: ClientCustomData.self, with: customData))
            }
        }
        else if let c = change as? ClientGuestChange {
            if _ID == 0 { _ID = c.ID }
            _guestID = c.guestID
        }
        else if let c = change as? ClientShortChange {
            if _ID == 0 { _ID = c.ID }
            _guestID = c.guestID
            _displayName = c.displayName ?? String()
            _avatarLink = c.avatarURL ?? _avatarLink
            
            if let channelID = c.channelID {
                _channelID = channelID
                _channel = context.object(Channel.self, primaryKey: channelID)
            }

            switch c.assignedAgentID {
            case .none: break
            case 0?: _assignedAgent = nil
            case .some(let agentID): _assignedAgent = context.agent(for: agentID, provideDefault: true)
            }
            
            _task = context.upsert(of: Task.self, with: c.task) ?? _task
        }
        else if let c = change as? ClientOnlineChange {
            _isOnline = c.isOnline
        }
        else if let c = change as? ClientHasActiveCallChange {
            _hasActiveCall = c.hasCall
        }
        else if let c = change as? ClientTaskChange {
            _task = context.object(Task.self, primaryKey: c.taskID)
        }
        else if let c = change as? ClientBlockingChange {
            _isBlocked = c.blocking
        }
        else if let c = change as? ClientAssignedAgentChange {
            switch c.agentID {
            case .none: _assignedAgent = nil
            case .some(let agentID): _assignedAgent = context.agent(for: agentID, provideDefault: true)
            }
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _customData.toArray(), recursive: true)
        context.customRemove(objects: [_activeSession, _proactiveRule, _task].flatten(), recursive: true)
    }
}

public final class ClientGeneralChange: BaseModelChange {
    public let ID: Int
    public let guestID: String
    public let chatID: Int?
    public let channelID: Int
    public let channelName: String?
    public let displayName: String?
    public let avatarURL: String?
    public let emailByClient: String?
    public let emailByAgent: String?
    public let phoneByClient: String?
    public let phoneByAgent: String?
    public let comment: String?
    public let visitsNumber: Int?
    public let navigatesNumber: Int?
    public let assignedAgentID: Int?
    public let activeSession: ClientSessionGeneralChange?
    public let socialLinks: [String: String]
    public let integration: String?
    public let connectionLost: Bool?
    public let hasStartup: Bool
    public let task: TaskGeneralChange?
    public let customData: [ClientCustomDataGeneralChange]?
    public let isBlocked: Bool

    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        guard ID > 0 else { return false }
        return true
    }
        public init(clientID: Int) {
        ID = clientID
        guestID = String()
        chatID = nil
        channelID = 0
        channelName = nil
        displayName = nil
        avatarURL = nil
        emailByClient = nil
        emailByAgent = nil
        phoneByClient = nil
        phoneByAgent = nil
        comment = nil
        visitsNumber = nil
        assignedAgentID = nil
        navigatesNumber = nil
        activeSession = nil
        socialLinks = [:]
        integration = nil
        connectionLost = nil
        hasStartup = true
        task = nil
        customData = nil
        isBlocked = false
        super.init()
    }
    
    required public init( json: JsonElement) {
        func _parseSocialLinks(source: JsonElement) -> [String: String] {
            var links = [String: String]()
            
            let replaceTypes: [String: String] = [
                "vkontakte": "vk",
                "facebook": "fb"
            ]
            
            source["social_profiles"].arrayValue.forEach { social in
                let type = social["type_name"].stringValue
                let link = social["url"].stringValue
                links[replaceTypes[type] ?? type] = link
            }
            
            source["socialProfiles"].arrayValue.forEach { social in
                let type = social["typeName"].stringValue
                let link = social["url"].stringValue
                links[replaceTypes[type] ?? type] = link
            }
            
            return links
        }
        
        if let ci = json.has(key: "client_info") {
            ID = ci["client_id"].int ?? json["client_id"].intValue
            guestID = ci["visitor_id"].string ?? json["visitor_id"].stringValue
            displayName = ci["agent_client_name"].valuable ?? ci["client_name"].valuable ?? ci["display_name"].valuable
            avatarURL = ci["avatar_url"].valuable
            emailByClient = ci["email"].valuable
            emailByAgent = ci["agent_client_email"].valuable
            phoneByClient = ci["phone"].valuable
            phoneByAgent = ci["agent_client_phone"].valuable
            comment = ci["description"].valuable
            visitsNumber = json["visits_count"].int
            assignedAgentID = ci["assigned_agent_id"].int
            navigatesNumber = json["navigated_count"].int
            activeSession = ci.parse()
            socialLinks = [:]
            customData = ci["custom_data"].parseList()
            hasStartup = (json["startup_seconds"].int != nil)
        }
        else {
            ID = json["client_id"].intValue
            guestID = json["visitor_id"].stringValue
            displayName = json["agent_client_name"].valuable ?? json["client_name"].valuable ?? json["display_name"].valuable
            avatarURL = json["avatar_url"].valuable
            emailByClient = json["email"].valuable
            emailByAgent = json["agent_client_email"].valuable
            phoneByClient = json["phone"].valuable
            phoneByAgent = json["agent_client_phone"].valuable
            comment = json["description"].valuable
            visitsNumber = json["visits_count"].int
            assignedAgentID = json["assigned_agent_id"].int
            navigatesNumber = json["navigated_count"].int
            activeSession = json["sessions"].arrayValue.first?.parse()
            socialLinks = _parseSocialLinks(source: json["social"])
            customData = json["custom_data"].parseList()
            hasStartup = true
        }
        
        chatID = json["chat_id"].int
        channelID = json["widget_id"].intValue
        channelName = json["widget_name"].string
        integration = json["has_integration"].string
        
        if let value = json["connection_lost"].int {
            connectionLost = (value > 0)
        }
        else {
            connectionLost = nil
        }

        task = json["reminder"].parse()
        isBlocked = (json.has(key: "blacklist") != nil)

        super.init(json: json)
    }
}

public final class ClientTypingChange: BaseModelChange {
    public let ID: Int
    public let chatID: Int
    public let input: String?

    public override var primaryValue: Int {
        return ID
    }
    public init(ID: Int, chatID: Int, input: String?) {
        self.ID = ID
        self.chatID = chatID
        self.input = input
        super.init()
    }

    required public init( json: JsonElement) {
        ID = json["client_id"].intValue
        chatID = json["chat_id"].intValue

        if let typing = json["typing"].int {
            input = (typing > 0 ? json["new_val"].stringValue : nil)
        }
        else {
            input = json["new_val"].stringValue.valuable
        }

        super.init(json: json)
    }

    public func copy(input: String?) -> ClientTypingChange {
        return ClientTypingChange(ID: ID, chatID: chatID, input: input)
    }

    public func copyWithoutInput() -> ClientTypingChange {
        return ClientTypingChange(ID: ID, chatID: chatID, input: nil)
    }
}

public final class ClientUTMChange: BaseModelChange {
    public let ID: Int
    public let UTM: ClientSessionUTMGeneralChange?
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["client_id"].intValue
        UTM = json["client_info"].parse()
        super.init(json: json)
    }
}

public final class ClientGuestChange: BaseModelChange {
    public let ID: Int
    public let guestID: String
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, guestID: String) {
        self.ID = ID
        self.guestID = guestID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientShortChange: BaseModelChange, NSCoding {
    public let ID: Int
    public let guestID: String
    public let channelID: Int?
    public let displayName: String?
    public let avatarURL: String?
    public let task: TaskGeneralChange?
    public let assignedAgentID: Int?

    private let codableIdKey = "id"
    private let codableGuestKey = "visitor"
    private let codableChannelKey = "channel"
    private let codableNameKey = "name"
    private let codableAvatarKey = "avatar"
    private let codableTaskKey = "reminder"
    private let codableAssignedAgentKey = "assigned_agent"

    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        return (ID > 0)
    }
    
    required public init( json: JsonElement) {
        ID = json["client_id"].intValue
        guestID = json["visitor_id"].stringValue
        channelID = json["widget_id"].int
        displayName = json["agent_client_name"].valuable ?? json["client_name"].valuable ?? json["display_name"].valuable
        avatarURL = json["avatar_url"].valuable
        task = json["reminder"].parse()
        assignedAgentID = json["assigned_agent_id"].int
        super.init(json: json)
    }
    
    public init(ID: Int, channelID: Int?, task: TaskGeneralChange?) {
        self.ID = ID
        self.guestID = String()
        self.channelID = channelID
        self.displayName = nil
        self.avatarURL = nil
        self.task = task
        self.assignedAgentID = 0
        super.init()
    }
    
    public init?(coder: NSCoder) {
        ID = coder.decodeInteger(forKey: codableIdKey)
        guestID = (coder.decodeObject(forKey: codableGuestKey) as? String) ?? String()
        channelID = coder.decodeObject(forKey: codableChannelKey) as? Int
        displayName = coder.decodeObject(forKey: codableNameKey) as? String
        avatarURL = coder.decodeObject(forKey: codableAvatarKey) as? String
        task = coder.decodeObject(of: TaskGeneralChange.self, forKey: codableTaskKey)
        assignedAgentID = coder.decodeObject(of: NSNumber.self, forKey: codableAssignedAgentKey)?.intValue
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ID, forKey: codableIdKey)
        coder.encode(guestID, forKey: codableGuestKey)
        coder.encode(channelID, forKey: codableChannelKey)
        coder.encode(displayName, forKey: codableNameKey)
        coder.encode(avatarURL, forKey: codableAvatarKey)
        coder.encode(task, forKey: codableTaskKey)
        coder.encode(assignedAgentID.flatMap(NSNumber.init), forKey: codableAssignedAgentKey)
    }
}

public final class ClientHistoryChange: BaseModelChange {
    private(set) public var messages = [MessageGeneralChange]()
    private(set) public var loadedEntirely: Bool = false
        public init(json: JsonElement, loadedEntirely: Bool) {
        super.init(json: json)
        self.loadedEntirely = loadedEntirely
        messages = json["messages"].parseList() ?? []
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientOnlineChange: BaseModelChange {
    public let ID: Int
    public let isOnline: Bool
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, isOnline: Bool) {
        self.ID = ID
        self.isOnline = isOnline
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientInaliveChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["client_id"].intValue
        super.init()
    }
}

public final class ClientHasActiveCallChange: BaseModelChange {
    public let ID: Int
    public let hasCall: Bool
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, hasCall: Bool) {
        self.ID = ID
        self.hasCall = hasCall
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientTaskChange: BaseModelChange {
    public let ID: Int
    public let taskID: Int

    public override var primaryValue: Int {
        return ID
    }
    public init(ID: Int, taskID: Int) {
        self.ID = ID
        self.taskID = taskID
        super.init()
    }

    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientBlockingChange: BaseModelChange {
    public let ID: Int
    public let blocking: Bool

    public override var primaryValue: Int {
        return ID
    }
    public init(ID: Int, blocking: Bool) {
        self.ID = ID
        self.blocking = blocking
        super.init()
    }

    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ClientAssignedAgentChange: BaseModelChange {
    public let ID: Int
    public let agentID: Int?

    public override var primaryValue: Int {
        return ID
    }
    public init(ID: Int, agentID: Int?) {
        self.ID = ID
        self.agentID = agentID
        super.init()
    }

    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

fileprivate func simplifyPhoneNumber(_ phone: String) -> String {
    let badSymbols = NSCharacterSet(charactersIn: "+0123456789").inverted
    return phone.components(separatedBy: badSymbols).joined()
}
