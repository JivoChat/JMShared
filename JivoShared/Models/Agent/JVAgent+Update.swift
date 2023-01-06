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
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVAgentGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _email = c.email.jv_valuable ?? _email
            _emailVerified = c.emailVerified ?? _emailVerified
            _phone = c.phone ?? _phone
            _stateID = c.stateID
            _status = context.upsert(of: JVAgentRichStatus.self, with: c.status)
            _statusComment = c.statusComment
            _avatarLink = c.avatarLink.jv_valuable
            _displayName = c.displayName
            _isOwner = c.isOwner ?? _isOwner
            _isAdmin = c.isAdmin
            _isOperator = c.isOperator
            _callingDestination = (c.callingDestination > -1 ? c.callingDestination : _callingDestination)
            _callingOptions = c.callingOptions
            _title = c.title
            _worktime = context.upsert(of: JVWorktime.self, with: c.worktime)
            _isWorking = c.isWorking ?? _isWorking
            _session = context.upsert(of: JVAgentSession.self, with: c.session) ?? _session
            _hasSession = (_session != nil)
            
            _orderingName = c.displayName
            adjustOrderingGroup()
        }
        else if let c = change as? JVAgentWorktimeChange {
            _worktime = context.upsert(of: JVWorktime.self, with: c.worktimeChange)
        }
        else if let c = change as? JVAgentShortChange {
            if _ID == 0 { _ID = c.ID }
            _email = c.email ?? _email
            _displayName = c.displayName
            
            _orderingName = c.displayName
        }
        else if let c = change as? JVAgentSdkChange {
            if _ID == 0 { _ID = c.id }
            _displayName = c.displayName
            _avatarLink = c.avatarLink
            c.title.flatMap { _title = $0 }
        }
        else if let c = change as? JVAgentStateChange {
            _stateID = c.state
            
            adjustOrderingGroup()
        }
        else if let c = change as? JVAgentLastMessageChange {
            if let key = c.messageGlobalKey {
                _lastMessage = context.object(JVMessage.self, mainKey: key)
            }
            else if let key = c.messageLocalKey {
                _lastMessage = context.object(JVMessage.self, mainKey: key)
            }
            
            _lastMessageDate = _lastMessage?.date
        }
        else if let c = change as? JVAgentChatChange {
            _chat = context.object(JVChat.self, primaryKey: c.chatID)
            _lastMessageDate = _chat?.lastMessage?.date
        }
        else if let c = change as? JVAgentDraftChange {
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
    
    public func performDelete(inside context: JVIDatabaseContext) {
        context.customRemove(objects: [_session, _worktime, _lastMessage, _chat].jv_flatten(), recursive: true)
    }
    
    private func adjustOrderingGroup() {
        switch JVAgentState(rawValue: _stateID) ?? .none {
        case .none: _orderingGroup = JVAgentOrderingGroup.offline.rawValue
        case .away where !_isWorking: _orderingGroup = JVAgentOrderingGroup.awayZZ.rawValue
        case .active where !_isWorking: _orderingGroup = JVAgentOrderingGroup.onlineZZ.rawValue
        case .away: _orderingGroup = JVAgentOrderingGroup.away.rawValue
        case .active: _orderingGroup = JVAgentOrderingGroup.online.rawValue
        }
    }
}

public final class JVAgentGeneralChange: JVBaseModelChange, Codable {
    public let json: JsonElement
    public let isMe: Bool
    public var ID: Int = 0
    public var siteID: Int
    public var email: String
    public var emailVerified: Bool?
    public var phone: String?
    public var stateID: Int = 0
    public var status: JVAgentRichStatusGeneralChange?
    public var statusComment: String = ""
    public var avatarLink: String
    public var displayName: String = ""
    public var title: String = ""
    public var callingDestination: Int
    public var callingOptions = 0
    public let isOwner: Bool?
    public let isAdmin: Bool
    public let isOperator: Bool
    public let isWorking: Bool?
    public let session: JVAgentSessionGeneralChange?
    public let worktime: JVWorktimeGeneralChange?

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
        phone = agentInfo["agent_phone"].string?.jv_valuable
        stateID = agentInfo["agent_state_id"].intValue
        status = agentInfo["agent_status"].parse()
        statusComment = agentInfo["agent_status"]["comment"].stringValue
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
        status = nil
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
         status: JVAgentRichStatusGeneralChange?,
         avatarLink: String,
         displayName: String,
         title: String,
         callingDestination: Int,
         callingOptions: Int,
         isOwner: Bool?,
         isAdmin: Bool,
         isOperator: Bool,
         isWorking: Bool?,
         session: JVAgentSessionGeneralChange?,
         worktime: JVWorktimeGeneralChange?) {
        self.json = json
        self.isMe = isMe
        self.ID = ID
        self.siteID = siteID
        self.email = email
        self.emailVerified = emailVerified
        self.phone = phone
        self.stateID = stateID
        self.status = status
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
    
    public func cachable() -> JVAgentGeneralChange {
        return JVAgentGeneralChange(
            json: json,
            isMe: isMe,
            ID: ID,
            siteID: siteID,
            email: email,
            emailVerified: emailVerified,
            phone: phone,
            stateID: 0,
            status: nil,
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

public final class JVAgentShortChange: JVBaseModelChange {
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

public final class JVAgentSdkChange: JVBaseModelChange {
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

public final class JVAgentLastMessageChange: JVBaseModelChange {
    public let ID: Int
    public let messageID: Int?
    public let messageLocalID: String?

    public override var primaryValue: Int {
        return ID
    }

    public var messageGlobalKey: JVDatabaseContextMainKey<Int>? {
        if let messageID = messageID {
            return JVDatabaseContextMainKey(key: "_ID", value: messageID)
        }
        else {
            return nil
        }
    }

    public var messageLocalKey: JVDatabaseContextMainKey<String>? {
        if let messageLocalID = messageLocalID {
            return JVDatabaseContextMainKey(key: "_localID", value: messageLocalID)
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

public final class JVAgentChatChange: JVBaseModelChange {
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

public final class JVAgentWorktimeChange: JVBaseModelChange {
    public let ID: Int
    public let worktimeChange: JVWorktimeBaseChange?
    
    public override var primaryValue: Int {
        return ID
    }
    
    public init(change: JVWorktimeBaseChange) {
        ID = change.agentID
        worktimeChange = change
        super.init()
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

public final class JVAgentStateChange: JVBaseModelChange {
    public let ID: Int
    public let state: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init(json: JsonElement) {
        if let sessionState = json.has(key: "state") {
            ID = 0
            
            switch sessionState.stringValue {
            case "online": state = JVAgentState.active.rawValue
            case "away": state = JVAgentState.away.rawValue
            default: state = JVAgentState.active.rawValue
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
    
    public func copy(meID: Int) -> JVAgentStateChange {
        if ID > 0 {
            return self
        }
        else {
            return JVAgentStateChange(ID: meID, state: state)
        }
    }
}

public final class JVAgentTypingChange: JVBaseModelChange {
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
            input = json["new_val"].stringValue.jv_valuable
        }

        super.init(json: json)
    }

    public func copy(typing: Bool) -> JVAgentTypingChange {
        return JVAgentTypingChange(ID: ID, chatID: chatID, input: input)
    }
}

public final class JVAgentDraftChange: JVBaseModelChange {
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
    case status(JVAgentState)
}

open class SDKAgentAtomChange: JVBaseModelChange {
    let id: Int
    let updates: [AgentPropertyUpdate]
    
    public override var primaryValue: Int {
        abort()
    }
    
    open override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey<Int>(key: "_ID", value: id)
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
func -->(node: JsonElement, option: JVAgentCallingOptions) -> Int {
    return node.intValue << option.rawValue
}
