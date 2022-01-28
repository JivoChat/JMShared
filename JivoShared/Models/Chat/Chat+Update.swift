//
//  JVChat+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVChat {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ChatGeneralChange {
            if _ID == 0 { _ID = c.ID }
            
            let previousRelation = _attendee?.relation
            
            if let lastChangeID = c.lastMessage?.ID {
                if let lastID = _lastMessage?.ID, lastID != lastChangeID {
                    _loadedPartialHistory = false
                    _loadedEntireHistory = false
                }
                else if _lastMessage == nil {
                    _loadedPartialHistory = true
                }
            }
            else if not(c.isGroup == true) {
                _loadedPartialHistory = false
                _loadedEntireHistory = false
            }
            
            if !c.attendees.isEmpty {
                let attendees = context.insert(of: ChatAttendee.self, with: c.attendees)
                _attendees.set(attendees.filter { $0.agent != nil })
            }
            else {
                _isArchived = true
            }
            
            _client = context.upsert(of: Client.self, with: c.client)

            if let clientID = c.client?.ID {
                context.setValue(clientID, for: c.ID)
                
                let parsedLastMessage = c.lastMessage?.attach(clientID: clientID)
                updateLastMessageIfNeeded(context: context, change: parsedLastMessage)

                let parsedActiveRing = c.activeRing?.attach(clientID: clientID)
                _activeRing = context.upsert(of: JVMessage.self, with: parsedActiveRing)

                _client?.apply(
                    inside: context,
                    with: ClientHasActiveCallChange(
                        ID: clientID,
                        hasCall: c.hasActiveCall
                    )
                )
            }
            else {
                if not(c.isGroup == true && c.lastMessage == nil) {
                    updateLastMessageIfNeeded(context: context, change: c.lastMessage)
                }

                _activeRing = context.upsert(of: JVMessage.self, with: c.activeRing)
            }

            if let attendeeIndex = _attendees.firstIndex(where: { $0.agent?.isMe == true }) {
                _attendee = _attendees[attendeeIndex]
                _attendees.remove(at: attendeeIndex)

                if let lastMessage = _lastMessage, lastMessage.ID <= c.receivedMessageID {
                    // do-nothing
                }
                else if let unreadNumber = c.unreadNumber {
                    _unreadNumber = unreadNumber
                }
                
                _requestCancelledBySystem = false
                _requestCancelledByAgent = nil
                _transferCancelled = false
                _terminationDate = nil
            }
            else {
                _attendee = _isArchived ? nil : _attendee
                _unreadNumber = -1
            }
            
            if c.attendees.isEmpty {
                _attendee = nil
                _attendees.set([])
                
                _requestCancelledBySystem = false
                _requestCancelledByAgent = nil
                _terminationDate = nil
            }
            
            if _attendee?.relation != previousRelation {
                _lastMessageValid = false
                
                _loadedPartialHistory = false
                _loadedEntireHistory = false
            }
            
            if let isGroup = c.isGroup {
                _isGroup = isGroup
            }
            
            if let isMain = c.isMain {
                _isMain = isMain
            }
            
            if let agentID = c.agentID {
                _owningAgent = context.agent(for: agentID, provideDefault: true)
            }
            
            _title = c.title
            _about = c.about ?? _about
            _icon = c.icon?.valuable?.convertToEmojis() ?? _icon

            _transferTo = nil
            _transferDate = nil
            _transferFailReason = nil
            
            _lastActivityTimestamp = (c.lastActivityTimestamp) ?? (_lastMessage?.date.timeIntervalSince1970) ?? 0
            if let notif = notifying, not(notif == .nothing) {
                _orderingBlock = 1
            }
            else {
                _orderingBlock = 0
            }
            
            _hasActiveCall = c.hasActiveCall
            _department = c.department
        }
        else if let c = change as? ChatShortChange {
            if _ID == 0 { _ID = c.ID }
            
            if let attendee = context.insert(of: ChatAttendee.self, with: c.attendee) {
                _attendee = attendee
            }
            
            _client = context.upsert(of: Client.self, with: c.client)
            
            _loadedEntireHistory = false
            _loadedPartialHistory = false
            
            _unreadNumber = -1
            
            _lastActivityTimestamp = Date().timeIntervalSince1970
            if let notif = notifying, not(notif == .nothing) {
                _orderingBlock = 1
            }
            else {
                _orderingBlock = 0
            }

            if let isGroup = c.isGroup {
                _isGroup = isGroup
            }
            
            _title = c.title
            _about = c.about ?? _about
            _icon = c.icon?.valuable?.convertToEmojis() ?? _icon
            _isArchived = c.isArchived
        }
        else if let c = change as? ChatLastMessageChange {
            let wantedMessage: JVMessage?
            if let key = c.messageGlobalKey {
                wantedMessage = context.object(JVMessage.self, mainKey: key)
            }
            else if let key = c.messageLocalKey {
                wantedMessage = context.object(JVMessage.self, mainKey: key)
            }
            else {
                wantedMessage = nil
            }
            
            if let cm = _lastMessage, let wm = wantedMessage, cm.isValid, wm.date < cm.date {
                // do nothing
            }
            else if let wm = wantedMessage {
                _lastMessage = wantedMessage
                _lastActivityTimestamp = max(_lastActivityTimestamp, wm.date.timeIntervalSince1970)
            }
            else {
                _lastMessage = nil
            }
        }
        else if let c = change as? ChatPreviewMessageChange {
            let wantedMessage: JVMessage?
            if let key = c.messageGlobalKey {
                wantedMessage = context.object(JVMessage.self, mainKey: key)
            }
            else if let key = c.messageLocalKey {
                wantedMessage = context.object(JVMessage.self, mainKey: key)
            }
            else {
                wantedMessage = nil
            }

            if let cm = _previewMessage, let wm = wantedMessage, wm.date < cm.date {
                // do nothing
            }
            else if let wm = wantedMessage {
                if wm.type == "comment" {
                    // skip, don't set
                }
                else {
                    _previewMessage = wantedMessage
                }
            }
            else {
                _previewMessage = nil
            }
        }
        else if let c = change as? ChatHistoryChange {
            _loadedPartialHistory = c.loadedPartialHistory ?? _loadedPartialHistory
            _loadedEntireHistory = c.loadedEntirely
            _lastMessageValid = c.lastMessageValid ?? _lastMessageValid
        }
        else if let _ = change as? ChatResetUnreadChange {
            _unreadNumber = -1
            
            _attendee?.apply(
                inside: context,
                with: ChatAttendeeResetUnreadChange(ID: 0, messageID: lastMessage?.ID ?? 0)
            )
        }
        else if let _ = change as? ChatIncrementUnreadChange {
            if _unreadNumber >= 0 {
                _unreadNumber += 1
            }
        }
        else if let c = change as? ChatTransferRequestChange {
            _transferTo = context.agent(for: c.agentID, provideDefault: true)
            _transferAssisting = c.assisting
            _transferDate = nil
            _transferComment = c.comment
            _transferFailReason = nil
        }
        else if let c = change as? ChatTransferCompleteChange {
            _transferDate = c.date
            _transferAssisting = c.assisting
        }
        else if let c = change as? ChatTransferRejectChange {
            if let agent = _transferTo {
                switch c.reason {
                case .rejectByAgent:
                    let name = agent.displayName(kind: .original)
                    _transferFailReason = c.assisting
                        ? loc[format: "Chat.System.Assist.Failed.RejectByAgent", name]
                        : loc[format: "Chat.System.Transfer.Failed.RejectByAgent", name]

                case .unknown:
                    _transferFailReason = c.assisting
                        ? loc["Chat.System.Assist.Failed.Unknown"]
                        : loc["Chat.System.Transfer.Failed.Unknown"]
                }
            }
            else {
                _transferTo = nil
                _transferDate = nil
                _transferFailReason = nil
            }
        }
        else if change is ChatTransferCancelChange {
            _transferTo = nil
            _transferDate = nil
            _transferFailReason = nil
        }
        else if change is ChatFinishedChange {
            _unreadNumber = -1
            _requestCancelledBySystem = true
            _requestCancelledByAgent = nil
            _transferCancelled = false
        }
        else if let c = change as? ChatRequestCancelledChange {
            let agent = context.agent(for: c.acceptedByID, provideDefault: true)
            
            _unreadNumber = -1
            _requestCancelledBySystem = false
            _requestCancelledByAgent = agent
            _transferCancelled = true
        }
        else if let _ = change as? ChatRequestCancelChange {
            _unreadNumber = -1
            _transferCancelled = true
        }
        else if let _ = change as? ChatAcceptChange {
            _attendee?.apply(inside: context, with: ChatAttendeeAcceptChange())
        }
        else if change is ChatAcceptFailChange {
            assertionFailure()
        }
        else if let c = change as? ChatTerminationChange {
            _terminationDate = c.date
        }
        else if let c = change as? ChatDraftChange {
            _draft = c.draft
        }
        else if let c = change as? SdkChatAgentsUpdateChange {
            if c.exclusive {
                _agents.set(c.agents)
            } else {
                _agents.append(objectsIn: c.agents)
            }
        }
        else {
            assertionFailure()
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _attendees.toArray(), recursive: true)
    }
    
    private func updateLastMessageIfNeeded(context: IDatabaseContext, change: MessageLocalChange?) {
        guard let message = _lastMessage else {
            _lastMessage = context.upsert(of: JVMessage.self, with: change)
            _lastActivityTimestamp = max(_lastActivityTimestamp, TimeInterval(change?.creationTS ?? 0))
            return
        }

        guard let change = change else {
            _lastMessage = nil
            return
        }

        let hasLaterID = (change.ID > message.ID)
        let hasLaterTime = (TimeInterval(change.creationTS) >= message.date.timeIntervalSince1970)

        guard hasLaterID || hasLaterTime else {
            return
        }

        if let _ = context.messageWithCallID(change.body?.callID) {
             _lastMessage = context.update(of: JVMessage.self, with: change.copy(ID: message.ID))
            _lastActivityTimestamp = max(_lastActivityTimestamp, TimeInterval(change.creationTS))
        }
        else {
            _lastMessage = context.upsert(of: JVMessage.self, with: change)
            _lastActivityTimestamp = max(_lastActivityTimestamp, TimeInterval(change.creationTS))
        }
    }
}

public final class ChatGeneralChange: BaseModelChange {
    public let ID: Int
    public let attendees: [ChatAttendeeGeneralChange]
    public let client: ClientShortChange?
    public let agentID: Int?
    public let lastMessage: MessageLocalChange?
    public let activeRing: MessageLocalChange?
    public let relation: String?
    public let isGroup: Bool?
    public let isMain: Bool?
    public let title: String?
    public let about: String?
    public let icon: String?
    public let receivedMessageID: Int
    public let unreadNumber: Int?
    public let lastActivityTimestamp: TimeInterval?
    public let hasActiveCall: Bool
    public let department: String?
    
    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        guard ID > 0 else { return false }
        return true
    }
    
    public init(ID: Int,
         attendees: [ChatAttendeeGeneralChange],
         client: ClientShortChange?,
         agentID: Int?,
         lastMessage: MessageLocalChange?,
         activeRing: MessageLocalChange?,
         relation: String?,
         isGroup: Bool?,
         isMain: Bool?,
         title: String?,
         about: String?,
         icon: String?,
         receivedMessageID: Int,
         unreadNumber: Int?,
         lastActivityTimestamp: TimeInterval?,
         hasActiveCall: Bool,
         department: String?) {
        self.ID = ID
        self.attendees = attendees
        self.client = client
        self.agentID = agentID
        self.lastMessage = lastMessage
        self.activeRing = activeRing
        self.relation = relation
        self.isGroup = isGroup
        self.isMain = isMain
        self.title = title
        self.about = about
        self.icon = icon
        self.receivedMessageID = receivedMessageID
        self.unreadNumber = unreadNumber
        self.lastActivityTimestamp = lastActivityTimestamp
        self.hasActiveCall = hasActiveCall
        self.department = department
        super.init()
    }
    
    required public init( json: JsonElement) {
        let parsedLastMessage: MessageLocalChange? = json["last_message"].parse()
        let parsedActiveRing: MessageLocalChange? = json["active_ring"].parse()
        
        ID = json["chat_id"].intValue
        client = json["client"].parse()
        agentID = json["agent_id"].int
        relation = nil
        isGroup = json["is_group"].bool
        isMain = json["is_main"].bool
        title = json["title"].string
        about = json["description"].string?.valuable
        icon = json["icon"].string
        receivedMessageID = 0
        unreadNumber = json["count_unread"].int
        
        if let _ = client {
            attendees = json["attendees"].parseList() ?? []
        }
        else {
            let values: [ChatAttendeeGeneralChange] = json["attendees"].parseList() ?? []
            attendees = values.map { $0.copy(relation: "") }
        }
        
        if let clientID = client?.ID {
            lastMessage = parsedLastMessage?.attach(clientID: clientID)
            activeRing = parsedActiveRing?.attach(clientID: clientID)
        }
        else {
            lastMessage = parsedLastMessage
            activeRing = parsedActiveRing
        }

        lastActivityTimestamp = json["latest_activity_date"].double
        hasActiveCall = (json.has(key: "active_call") != nil)
        department = json["department"]["display_name"].string

        super.init(json: json)
    }
    
    public func copy(without me: JVAgent) -> ChatGeneralChange {
        if let meAttendee = attendees.first(where: { $0.ID == me.ID }) ?? attendees.first {
            return ChatGeneralChange(
                ID: ID,
                attendees: attendees.filter({ $0 !== meAttendee }),
                client: client,
                agentID: agentID,
                lastMessage: lastMessage,
                activeRing: activeRing,
                relation: meAttendee.relation,
                isGroup: isGroup,
                isMain: isMain,
                title: title,
                about: about,
                icon: icon,
                receivedMessageID: receivedMessageID,
                unreadNumber: unreadNumber,
                lastActivityTimestamp: lastActivityTimestamp,
                hasActiveCall: hasActiveCall,
                department: department)
        }
        else {
            return self
        }
    }

    public func copy(relation: String, everybody: Bool) -> ChatGeneralChange {
        guard attendees.count == 1 || everybody else { return self }

        return ChatGeneralChange(
            ID: ID,
            attendees: attendees.map { $0.copy(relation: relation) },
            client: client,
            agentID: agentID,
            lastMessage: lastMessage,
            activeRing: activeRing,
            relation: relation,
            isGroup: isGroup,
            isMain: isMain,
            title: title,
            about: about,
            icon: icon,
            receivedMessageID: receivedMessageID,
            unreadNumber: unreadNumber,
            lastActivityTimestamp: lastActivityTimestamp,
            hasActiveCall: hasActiveCall,
            department: department)
    }
    
    public func copy(receivedMessageID: Int) -> ChatGeneralChange {
        return ChatGeneralChange(
            ID: ID,
            attendees: attendees,
            client: client,
            agentID: agentID,
            lastMessage: lastMessage,
            activeRing: activeRing,
            relation: relation,
            isGroup: isGroup,
            isMain: isMain,
            title: title,
            about: about,
            icon: icon,
            receivedMessageID: receivedMessageID,
            unreadNumber: unreadNumber,
            lastActivityTimestamp: lastActivityTimestamp,
            hasActiveCall: hasActiveCall,
            department: department)
    }
    
    public func cachable() -> ChatGeneralChange {
        return ChatGeneralChange(
            ID: ID,
            attendees: attendees.map { $0.cachable() },
            client: client,
            agentID: agentID,
            lastMessage: lastMessage,
            activeRing: activeRing,
            relation: relation,
            isGroup: isGroup,
            isMain: isMain,
            title: title,
            about: about,
            icon: icon,
            receivedMessageID: receivedMessageID,
            unreadNumber: 0,
            lastActivityTimestamp: lastActivityTimestamp,
            hasActiveCall: hasActiveCall,
            department: department)
    }
    
    public func findAttendeeRelation(agentID: Int) -> String? {
        for attendee in attendees {
            guard attendee.ID == agentID else { continue }
            return attendee.relation
        }
        
        return nil
    }
}

public final class ChatShortChange: BaseModelChange, NSCoding {
    public let ID: Int
    public let client: ClientShortChange?
    public let attendee: ChatAttendeeGeneralChange?
    public let relation: String?
    public let teammateID: Int?
    public let isGroup: Bool?
    public let title: String?
    public let about: String?
    public let icon: String?
    public let isArchived: Bool
    
    private let codableIdKey = "id"
    private let codableClientKey = "client"
    private let codableAttendeeKey = "attendee"
    private let codableRelationKey = "relation"
    private let codableTeammateKey = "teammate"
    private let codableGroupKey = "group"
    private let codableTitleKey = "title"
    private let codableAboutKey = "about"
    private let codableIconKey = "icon"
    private let codableArchivedKey = "is_archived"
    
    public override var primaryValue: Int {
        return ID
    }
    
    public convenience init(ID: Int, clientID: Int) {
        self.init(
            ID: ID,
            client: ClientShortChange(
                ID: clientID,
                channelID: nil,
                task: nil),
            attendee: nil,
            teammateID: nil,
            isGroup: nil,
            title: nil,
            about: nil,
            icon: nil,
            isArchived: true)
    }
    
    public init(
        ID: Int,
        client: ClientShortChange?,
        attendee: ChatAttendeeGeneralChange?,
        teammateID: Int?,
        isGroup: Bool?,
        title: String?,
        about: String?,
        icon: String?,
        isArchived: Bool
    ) {
        self.ID = ID
        self.client = client
        self.attendee = attendee
        self.teammateID = teammateID
        self.relation = attendee?.relation
        self.isGroup = isGroup
        self.title = title
        self.about = about
        self.icon = icon
        self.isArchived = isArchived
        super.init()
    }
    
    required public init( json: JsonElement) {
        ID = json["chat_id"].intValue
        client = json["client"].parse()
        attendee = nil
        relation = json["rel"].string ?? "invited"
        teammateID = nil
        isGroup = json["is_group"].bool
        title = json["title"].string
        about = json["about"].string
        icon = json["icon"].string
        isArchived = false
        super.init(json: json)
    }
    
    public init?(coder: NSCoder) {
        ID = coder.decodeInteger(forKey: codableIdKey)
        client = coder.decodeObject(of: ClientShortChange.self, forKey: codableClientKey)
        attendee = coder.decodeObject(of: ChatAttendeeGeneralChange.self, forKey: codableAttendeeKey)
        relation = coder.decodeObject(forKey: codableRelationKey) as? String
        teammateID = coder.decodeObject(forKey: codableTeammateKey) as? Int
        isGroup = coder.decodeObject(of: NSNumber.self, forKey: codableGroupKey)?.boolValue
        title = coder.decodeObject(forKey: codableTitleKey) as? String
        about = coder.decodeObject(forKey: codableAboutKey) as? String
        icon = coder.decodeObject(forKey: codableIconKey) as? String
        isArchived = coder.decodeBool(forKey: codableArchivedKey)
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ID, forKey: codableIdKey)
        coder.encode(client, forKey: codableClientKey)
        coder.encode(attendee, forKey: codableAttendeeKey)
        coder.encode(relation, forKey: codableRelationKey)
        coder.encode(teammateID, forKey: codableTeammateKey)
        coder.encode(isGroup.flatMap(NSNumber.init), forKey: codableGroupKey)
        coder.encode(title, forKey: codableTitleKey)
        coder.encode(about, forKey: codableAboutKey)
        coder.encode(icon, forKey: codableIconKey)
        coder.encode(isArchived, forKey: codableArchivedKey)
    }
    
    public func copy(attendeeID: Int,
              rel: String?,
              comment: String?,
              invitedBy: Int?,
              isAssistant: Bool) -> ChatShortChange {
        return ChatShortChange(
            ID: ID,
            client: client,
            attendee: ChatAttendeeGeneralChange(
                ID: attendeeID,
                relation: rel ?? relation,
                comment: comment,
                invitedBy: invitedBy,
                isAssistant: isAssistant,
                receivedMessageID: 0,
                unreadNumber: 0,
                notifications: nil
            ),
            teammateID: teammateID,
            isGroup: isGroup,
            title: title,
            about: about,
            icon: icon,
            isArchived: isArchived
        )
    }
}

public final class ChatLastMessageChange: BaseModelChange {
    public let chatID: Int
    public let messageID: Int?
    public let messageLocalID: String?
    
    public override var primaryValue: Int {
        return chatID
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
    
    public init(chatID: Int, messageID: Int?, messageLocalID: String?) {
        self.chatID = chatID
        self.messageID = messageID
        self.messageLocalID = messageLocalID
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatPreviewMessageChange: BaseModelChange {
    public let chatID: Int
    public let messageID: Int?
    public let messageLocalID: String?

    public override var primaryValue: Int {
        return chatID
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
    
    public init(chatID: Int, messageID: Int?, messageLocalID: String?) {
        self.chatID = chatID
        self.messageID = messageID
        self.messageLocalID = messageLocalID
        super.init()
    }

    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatHistoryChange: BaseModelChange {
    public let loadedPartialHistory: Bool?
    public let loadedEntirely: Bool
    public let lastMessageValid: Bool?
    
    public init(loadedPartialHistory: Bool?, loadedEntirely: Bool, lastMessageValid: Bool?) {
        self.loadedPartialHistory = loadedPartialHistory
        self.loadedEntirely = loadedEntirely
        self.lastMessageValid = lastMessageValid
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatIncrementUnreadChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int) {
        self.ID = ID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatResetUnreadChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int) {
        self.ID = ID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatTransferRequestChange: BaseModelChange {
    public let ID: Int
    public let agentID: Int
    public let assisting: Bool
    public let comment: String?
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int, agentID: Int, assisting: Bool, comment: String?) {
        self.ID = ID
        self.agentID = agentID
        self.assisting = assisting
        self.comment = comment
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatTransferCompleteChange: BaseModelChange {
    public let ID: Int
    public let date: Date
    public let assisting: Bool
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["chat_id"].intValue
        date = Date()
        assisting = json["assistant"].boolValue
        super.init(json: json)
    }
}

public final class ChatTransferRejectChange: BaseModelChange {
    public enum Reason: String {
        case rejectByAgent = "target_agent_reject"
        case unknown
    }
    
    public let ID: Int
    public let assisting: Bool
    public let reason: Reason
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["chat_id"].intValue
        assisting = json["assistant"].boolValue
        reason = Reason(rawValue: json["reason"].stringValue) ?? .unknown
        super.init(json: json)
    }
}

public final class ChatTransferCancelChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int) {
        self.ID = ID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatFinishedChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        self.ID = json["chat_id"].intValue
        super.init(json: json)
    }
        public init(ID: Int) {
        self.ID = ID
        super.init()
    }
}

public final class ChatRequestCancelledChange: BaseModelChange {
    public let ID: Int
    public let acceptedByID: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    public init(ID: Int, acceptedByID: Int) {
        self.ID = ID
        self.acceptedByID = acceptedByID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatRequestCancelChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
        public init(ID: Int) {
        self.ID = ID
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatAcceptChange: BaseModelChange {
    public let ID: Int
    public let clientID: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["chat_id"].intValue
        clientID = json["client_id"].intValue
        super.init(json: json)
    }
}

public final class ChatAcceptFailChange: BaseModelChange {
    public enum Reason: String {
        case alreadyAccepted = "client_already_has_agent_id"
        case hasCall = "chat_has_cw_call"
        case unknown
    }
    
    public let ID: Int
    public let clientID: Int
    public let acceptedAgentID: Int?
    public let reason: Reason
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        ID = json["chat_id"].intValue
        clientID = json["client_id"].intValue
        acceptedAgentID = json["accepted_agent_id"].intValue.valuable
        reason = Reason(rawValue: json["reason"].stringValue) ?? .unknown
        super.init(json: json)
    }
}

public final class ChatTerminationChange: BaseModelChange {
    public let ID: Int
    public let date: Date
    
    public override var primaryValue: Int {
        return ID
    }
    
    public init(ID: Int, delay: TimeInterval) {
        self.ID = ID
        self.date = Date().addingTimeInterval(delay)
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class ChatDraftChange: BaseModelChange {
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
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class SdkChatAgentsUpdateChange: BaseModelChange {
    public let id: Int
    public let agents: [JVAgent]
    public let exclusive: Bool
    
    public override var primaryValue: Int {
        return id
    }
    
    public init(id: Int, agents: [JVAgent], exclusive: Bool) {
        self.id = id
        self.agents = agents
        self.exclusive = exclusive
        
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

