//
//  JVAgent+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVAgent {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? AgentGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _email = c.email.valuable ?? _email
            _emailVerified = c.emailVerified ?? _emailVerified
            _phone = c.phone ?? _phone
            _stateID = c.stateID
            _avatarLink = c.avatarLink.valuable
            _displayName = c.displayName
            _isOwner = c.isOwner ?? _isOwner
            _isAdmin = c.isAdmin
            _isOperator = c.isOperator
            _callingDestination = (c.callingDestination > -1 ? c.callingDestination : _callingDestination)
            _callingOptions = c.callingOptions
            _title = c.title
            _worktime = context.upsert(of: Worktime.self, with: c.worktime)
            _isWorking = c.isWorking ?? _isWorking
            _session = context.upsert(of: AgentSession.self, with: c.session) ?? _session
            _hasSession = (_session != nil)
            
            _orderingName = c.displayName
            adjustOrderingGroup()
        }
        else if let c = change as? AgentWorktimeChange {
            _worktime = context.upsert(of: Worktime.self, with: c.worktimeChange)
        }
        else if let c = change as? AgentShortChange {
            if _ID == 0 { _ID = c.ID }
            _email = c.email ?? _email
            _displayName = c.displayName
            
            _orderingName = c.displayName
        }
        else if let c = change as? AgentSdkChange {
            if _ID == 0 { _ID = c.id }
            _displayName = c.displayName
            _avatarLink = c.avatarLink
            c.title.flatMap { _title = $0 }
        }
        else if let c = change as? AgentStateChange {
            _stateID = c.state
            
            adjustOrderingGroup()
        }
        else if let c = change as? AgentLastMessageChange {
            if let key = c.messageGlobalKey {
                _lastMessage = context.object(JVMessage.self, mainKey: key)
            }
            else if let key = c.messageLocalKey {
                _lastMessage = context.object(JVMessage.self, mainKey: key)
            }
            
            _lastMessageDate = _lastMessage?.date
        }
        else if let c = change as? AgentChatChange {
            _chat = context.object(Chat.self, primaryKey: c.chatID)
            _lastMessageDate = _chat?.lastMessage?.date
        }
        else if let c = change as? AgentDraftChange {
            _draft = c.draft
        }
        else if let c = change as? SDKAgentAtomChange {
            if _ID == 0 { _ID = c.id }
            
            c.updates.forEach { update in
                switch update {
                case let .displayName(newDisplayName):
                    _displayName = newDisplayName
                    
                case let .title(newTitle):
                    _title = newTitle
                    
                case let .avatarLink(avatarLinkURL):
                    _avatarLink = avatarLinkURL?.absoluteString
                    
                case let .status(newState):
                    state = newState
                }
            }
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: [_session, _worktime, _lastMessage, _chat].flatten(), recursive: true)
    }
    
    private func adjustOrderingGroup() {
        switch AgentState(rawValue: _stateID) ?? .none {
        case .none: _orderingGroup = AgentOrderingGroup.offline.rawValue
        case .away where !_isWorking: _orderingGroup = AgentOrderingGroup.awayZZ.rawValue
        case .active where !_isWorking: _orderingGroup = AgentOrderingGroup.onlineZZ.rawValue
        case .away: _orderingGroup = AgentOrderingGroup.away.rawValue
        case .active: _orderingGroup = AgentOrderingGroup.online.rawValue
        }
    }
}

public final class AgentGeneralChange: BaseModelChange, Codable {
    public let json: JsonElement
    public let isMe: Bool
    public var ID: Int = 0
    public var siteID: Int
    public var email: String
    public var emailVerified: Bool?
    public var phone: String?
    public var stateID: Int = 0
    public var avatarLink: String
    public var displayName: String = ""
    public var title: String = ""
    public var callingDestination: Int
    public var callingOptions = 0
    public let isOwner: Bool?
    public let isAdmin: Bool
    public let isOperator: Bool
    public let isWorking: Bool?
    public let session: AgentSessionGeneralChange?
    public let worktime: WorktimeGeneralChange?

    public override var primaryValue: Int {
        return ID
    }
    
    public init(json: JsonElement, isMe: Bool) {
        self.json = json
        self.isMe = isMe
        
        let agentInfo = json.has(key: "agent_info") ?? json
        let flags: [Int] = [
            json["rmo_state"]["available_for_calls"] --> .availableForCalls,
            json["rmo_state"]["available_for_mobile_calls"] --> .availableForMobileCalls,
            json["rmo_state"]["on_call"] --> .onCall,
            json["calls_away"] --> .supportsAway,
            json["calls_offline"] --> .supportsOffline
        ]
        
        ID = agentInfo["agent_id"].intValue
        siteID = agentInfo["site_id"].intValue
        email = agentInfo["email"].stringValue
        emailVerified = agentInfo["email_verified"].bool
        phone = agentInfo["agent_phone"].string?.valuable
        stateID = agentInfo["agent_state_id"].intValue
        avatarLink = agentInfo["avatar_url"].stringValue
        displayName = agentInfo["display_name"].stringValue
        title = agentInfo["title"].stringValue
        callingDestination = agentInfo["web_call_dest"].int ?? -1
        callingOptions = flags.reduce(0, +)
        isOwner = agentInfo["is_owner"].bool
        isAdmin = agentInfo["is_admin"].bool ?? true
        isOperator = agentInfo["is_operator"].bool ?? true
        isWorking = agentInfo["work_state"].int.flatMap { $0 > 0 }
        session = json.parse()
        worktime = json.parse()
        
        super.init(json: json)
    }
    
    public init(placeholderID: Int) {
        json = JsonElement()
        isMe = false
        ID = placeholderID
        siteID = 0
        email = String()
        phone = nil
        stateID = 0
        avatarLink = String()
        displayName = "(\(loc["Agent.DisplayName.Deleted"]))"
        title = ""
        callingDestination = -1
        callingOptions = 0
        isOwner = nil
        isAdmin = false
        isOperator = false
        isWorking = true
        session = nil
        worktime = nil
        super.init()
    }
    
    public init(json: JsonElement,
         isMe: Bool,
         ID: Int,
         siteID: Int,
         email: String,
         emailVerified: Bool?,
         phone: String?,
         stateID: Int,
         avatarLink: String,
         displayName: String,
         title: String,
         callingDestination: Int,
         callingOptions: Int,
         isOwner: Bool?,
         isAdmin: Bool,
         isOperator: Bool,
         isWorking: Bool?,
         session: AgentSessionGeneralChange?,
         worktime: WorktimeGeneralChange?) {
        self.json = json
        self.isMe = isMe
        self.ID = ID
        self.siteID = siteID
        self.email = email
        self.emailVerified = emailVerified
        self.phone = phone
        self.stateID = stateID
        self.avatarLink = avatarLink
        self.displayName = displayName
        self.title = title
        self.callingDestination = callingDestination
        self.callingOptions = callingOptions
        self.isOwner = isOwner
        self.isAdmin = isAdmin
        self.isOperator = isOperator
        self.isWorking = isWorking
        self.session = session
        self.worktime = worktime
        super.init()
    }
    
    required public convenience init(json: JsonElement) {
        self.init(json: json, isMe: false)
    }
    
    public func cachable() -> AgentGeneralChange {
        return AgentGeneralChange(
            json: json,
            isMe: isMe,
            ID: ID,
            siteID: siteID,
            email: email,
            emailVerified: emailVerified,
            phone: phone,
            stateID: 0,
            avatarLink: avatarLink,
            displayName: displayName,
            title: title,
            callingDestination: callingDestination,
            callingOptions: callingOptions,
            isOwner: isOwner,
            isAdmin: isAdmin,
            isOperator: isOperator,
            isWorking: isWorking,
            session: session,
            worktime: worktime)
    }
}

public final class AgentShortChange: BaseModelChange {
    public let ID: Int
    public let email: String?
    public let displayName: String
    
    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        return (ID > 0)
    }
    
    required public init(json: JsonElement) {
        ID = json["agent_id"].intValue
        email = json["email"].string
        displayName = json["display_name"].stringValue
        super.init(json: json)
    }
}

public final class AgentSdkChange: BaseModelChange {
    
    public let id: Int
    public let avatarLink: String?
    public let displayName: String
    public let title: String?
    
    public override var primaryValue: Int {
        return id
    }
    
    public override var isValid: Bool {
        return (id > 0)
    }
    
    public init(
        id: Int,
        avatarLink: String? = nil,
        displayName: String,
        title: String? = nil
    ) {
        self.id = id
        self.avatarLink = avatarLink
        self.displayName = displayName
        self.title = title
        
        super.init()
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

public final class AgentLastMessageChange: BaseModelChange {
    public let ID: Int
    public let messageID: Int?
    public let messageLocalID: String?

    public override var primaryValue: Int {
        return ID
    }

    public var messageGlobalKey: DatabaseContextMainKey<Int>? {
        if let messageID = messageID {
            return DatabaseContextMainKey(key: "_ID", value: messageID)
        }
        else {
            return nil
        }
    }

    public var messageLocalKey: DatabaseContextMainKey<String>? {
        if let messageLocalID = messageLocalID {
            return DatabaseContextMainKey(key: "_localID", value: messageLocalID)
        }
        else {
            return nil
        }
    }
    public init(ID: Int, messageID: Int?, messageLocalID: String?) {
        self.ID = ID
        self.messageID = messageID
        self.messageLocalID = messageLocalID
        super.init()
    }

    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class AgentChatChange: BaseModelChange {
    public let ID: Int
    public let chatID: Int
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, chatID: Int) {
        self.ID = ID
        self.chatID = chatID
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class AgentWorktimeChange: BaseModelChange {
    public let ID: Int
    public let worktimeChange: WorktimeBaseChange?
    
    public override var primaryValue: Int {
        return ID
    }
        public init(change: WorktimeBaseChange) {
        ID = change.agentID
        worktimeChange = change
        super.init()
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

public final class AgentStateChange: BaseModelChange {
    public let ID: Int
    public let state: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init(json: JsonElement) {
        if let sessionState = json.has(key: "state") {
            ID = 0
            
            switch sessionState.stringValue {
            case "online": state = AgentState.active.rawValue
            case "away": state = AgentState.away.rawValue
            default: state = AgentState.active.rawValue
            }
        }
        else {
            ID = json["agent_id"].intValue
            state = json["agent_state_id"].intValue
        }
        
        super.init(json: json)
    }
        public init(ID: Int, state: Int) {
        self.ID = ID
        self.state = state
        super.init()
    }
    
    public func copy(meID: Int) -> AgentStateChange {
        if ID > 0 {
            return self
        }
        else {
            return AgentStateChange(ID: meID, state: state)
        }
    }
}

public final class AgentTypingChange: BaseModelChange {
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

    required public init(json: JsonElement) {
        ID = json["agent_id"].intValue
        chatID = json["chat_id"].intValue

        if let typing = json["typing"].int {
            input = (typing > 0 ? json["new_val"].stringValue : nil)
        }
        else {
            input = json["new_val"].stringValue.valuable
        }

        super.init(json: json)
    }

    public func copy(typing: Bool) -> AgentTypingChange {
        return AgentTypingChange(ID: ID, chatID: chatID, input: input)
    }
}

public final class AgentDraftChange: BaseModelChange {
    public let ID: Int
    public let draft: String?
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, draft: String?) {
        self.ID = ID
        self.draft = draft
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public enum AgentPropertyUpdate {
    case displayName(String)
    case title(String)
    case avatarLink(URL?)
    case status(AgentState)
}

open class SDKAgentAtomChange: BaseModelChange {
    let id: Int
    let updates: [AgentPropertyUpdate]
    
    public override var primaryValue: Int {
        abort()
    }
    
    open override var integerKey: DatabaseContextMainKey<Int>? {
        return DatabaseContextMainKey<Int>(key: "_ID", value: id)
    }
    
    public init(id: Int, updates: [AgentPropertyUpdate]) {
        self.id = id
        self.updates = updates
        
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

infix operator -->
func -->(node: JsonElement, option: AgentCallingOptions) -> Int {
    return node.intValue << option.rawValue
}
