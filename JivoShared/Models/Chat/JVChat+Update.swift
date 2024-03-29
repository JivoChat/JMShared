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
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVChatGeneralChange {
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
            else if !(c.isGroup == true) {
                _loadedPartialHistory = false
                _loadedEntireHistory = false
            }
            
            if c.knownArchived {
                _isArchived = true
                _loadedPartialHistory = false
            }
            else if !c.attendees.isEmpty {
                let attendees = context.insert(of: JVChatAttendee.self, with: c.attendees)
                _attendees.jv_set(attendees.filter { $0.agent != nil })
            }
            else {
                _isArchived = true
            }
            
            _client = context.upsert(of: JVClient.self, with: c.client)

            if let clientID = c.client?.ID {
                context.setValue(clientID, for: c.ID)
                
                let parsedLastMessage = c.lastMessage?.attach(clientID: clientID)
                updateLastMessageIfNeeded(context: context, change: parsedLastMessage)

                let parsedActiveRing = c.activeRing?.attach(clientID: clientID)
                _activeRing = context.upsert(of: JVMessage.self, with: parsedActiveRing)

                _client?.apply(
                    inside: context,
                    with: JVClientHasActiveCallChange(
                        ID: clientID,
                        hasCall: c.hasActiveCall
                    )
                )
            }
            else {
                if !(c.isGroup == true && c.lastMessage == nil) {
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
                _attendees.jv_set([])
                
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
            _icon = c.icon?.jv_valuable?.jv_convertToEmojis() ?? _icon

            _transferTo = nil
            _transferToDepartment = nil
            _transferDate = nil
            _transferFailReason = nil
            
            _lastActivityTimestamp = (c.lastActivityTimestamp) ?? (_lastMessage?.date.timeIntervalSince1970) ?? 0
            if let notif = notifying, !(notif == .nothing) {
                _orderingBlock = 1
            }
            else {
                _orderingBlock = 0
            }
            
            _hasActiveCall = c.hasActiveCall
            _department = c.department
        }
        else if let c = change as? JVChatShortChange {
            if _ID == 0 { _ID = c.ID }
            
            if let attendee = context.insert(of: JVChatAttendee.self, with: c.attendee) {
                _attendee = attendee
            }
            
            _client = context.upsert(of: JVClient.self, with: c.client)
            
            _loadedEntireHistory = false
            _loadedPartialHistory = false
            
            _unreadNumber = -1
            
            _lastActivityTimestamp = Date().timeIntervalSince1970
            if let notif = notifying, !(notif == .nothing) {
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
            _icon = c.icon?.jv_valuable?.jv_convertToEmojis() ?? _icon
            _isArchived = c.isArchived
        }
        else if let c = change as? JVChatLastMessageChange {
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
            
            if let cm = _lastMessage, let wm = wantedMessage, cm.jv_isValid, wm.date < cm.date {
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
        else if let c = change as? JVChatPreviewMessageChange {
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
        else if let c = change as? JVChatHistoryChange {
            _loadedPartialHistory = c.loadedPartialHistory ?? _loadedPartialHistory
            _loadedEntireHistory = c.loadedEntirely
            _lastMessageValid = c.lastMessageValid ?? _lastMessageValid
        }
        else if let _ = change as? JVChatResetUnreadChange {
            _unreadNumber = -1
            
            _attendee?.apply(
                inside: context,
                with: JVChatAttendeeResetUnreadChange(ID: 0, messageID: lastMessage?.ID ?? 0)
            )
        }
        else if let _ = change as? JVChatIncrementUnreadChange {
            if _unreadNumber >= 0 {
                _unreadNumber += 1
            }
        }
        else if let c = change as? JVChatTransferRequestChange {
            _transferTo = c.agentID.flatMap { context.agent(for: $0, provideDefault: true) }
            _transferToDepartment = c.departmentID.flatMap { context.department(for: $0) }
            _transferAssisting = c.assisting
            _transferDate = nil
            _transferComment = c.comment
            _transferFailReason = nil
        }
        else if let c = change as? JVChatTransferCompleteChange {
            _transferDate = c.date
            _transferAssisting = c.assisting
        }
        else if let c = change as? JVChatTransferRejectChange {
            if let agent = _transferTo {
                switch c.reason {
                case .rejectByAgent:
                    let name = agent.displayName(kind: .original)
                    _transferFailReason = c.assisting
                        ? loc[format: "Chat.System.Assist.Failed.RejectByAgent", name]
                        : loc[format: "Chat.System.Transfer.Failed.RejectByAgent", name]

                case .rejectByDepartment, .unknown:
                    _transferFailReason = c.assisting
                        ? loc["Chat.System.Assist.Failed.Unknown"]
                        : loc["Chat.System.Transfer.Failed.Unknown"]
                }
            }
            else if let department = _transferToDepartment {
                switch c.reason {
                case .rejectByDepartment:
                    let name = department.displayName(kind: .original)
                    _transferFailReason = loc[format: "Chat.System.Transfer.Failed.RejectByDepartment", name]

                case .rejectByAgent, .unknown:
                    _transferFailReason = loc["Chat.System.Transfer.Failed.Unknown"]
                }
            }
            else {
                _transferTo = nil
                _transferToDepartment = nil
                _transferDate = nil
                _transferFailReason = nil
            }
        }
        else if change is JVChatTransferCancelChange {
            _transferTo = nil
            _transferToDepartment = nil
            _transferDate = nil
            _transferFailReason = nil
        }
        else if change is JVChatFinishedChange {
            _unreadNumber = -1
            _requestCancelledBySystem = true
            _requestCancelledByAgent = nil
            _transferCancelled = false
        }
        else if let c = change as? JVChatRequestCancelledChange {
            let agent = context.agent(for: c.acceptedByID, provideDefault: true)
            
            _unreadNumber = -1
            _requestCancelledBySystem = false
            _requestCancelledByAgent = agent
            _transferCancelled = true
        }
        else if let _ = change as? JVChatRequestCancelChange {
            _unreadNumber = -1
            _transferCancelled = true
        }
        else if let _ = change as? JVChatAcceptChange {
            _attendee?.apply(inside: context, with: JVChatAttendeeAcceptChange())
        }
        else if change is JVChatAcceptFailChange {
            assertionFailure()
        }
        else if let c = change as? JVChatTerminationChange {
            _terminationDate = c.date
        }
        else if let c = change as? JVChatDraftChange {
            _draft = c.draft
        }
        else if let c = change as? JVSdkChatAgentsUpdateChange {
            if c.exclusive {
                _agents.jv_set(c.agents)
            } else {
                c.agents.forEach { agent in
                    if !_agents.contains(where: { $0.ID == agent.ID }) {
                        _agents.append(agent)
                    }
                }
            }
        }
        else {
            assertionFailure()
        }
    }
    
    public func performDelete(inside context: JVIDatabaseContext) {
        context.customRemove(objects: _attendees.jv_toArray(), recursive: true)
    }
    
    private func updateLastMessageIfNeeded(context: JVIDatabaseContext, change: JVMessageLocalChange?) {
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

public final class JVChatGeneralChange: JVBaseModelChange {
    public let ID: Int
    public let attendees: [JVChatAttendeeGeneralChange]
    public let client: JVClientShortChange?
    public let agentID: Int?
    public let lastMessage: JVMessageLocalChange?
    public let activeRing: JVMessageLocalChange?
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
    public let knownArchived: Bool

    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        guard ID > 0 else { return false }
        return true
    }
    
    public init(ID: Int,
         attendees: [JVChatAttendeeGeneralChange],
         client: JVClientShortChange?,
         agentID: Int?,
         lastMessage: JVMessageLocalChange?,
         activeRing: JVMessageLocalChange?,
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
         department: String?,
         knownArchived: Bool) {
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
        self.knownArchived = knownArchived
        super.init()
    }
    
    required public init( json: JsonElement) {
        let parsedLastMessage: JVMessageLocalChange? = json["last_message"].parse()
        let parsedActiveRing: JVMessageLocalChange? = json["active_ring"].parse()
        
        ID = json["chat_id"].intValue
        client = json["client"].parse()
        agentID = json["agent_id"].int
        relation = nil
        isGroup = json["is_group"].bool
        isMain = json["is_main"].bool
        title = json["title"].string
        about = json["description"].string?.jv_valuable
        icon = json["icon"].string
        receivedMessageID = 0
        unreadNumber = json["count_unread"].int
        
        if let _ = client {
            attendees = json["attendees"].parseList() ?? []
        }
        else {
            let values: [JVChatAttendeeGeneralChange] = json["attendees"].parseList() ?? []
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
        knownArchived = false

        super.init(json: json)
    }
    
    public func copy(without me: JVAgent) -> JVChatGeneralChange {
        if let meAttendee = attendees.first(where: { $0.ID == me.ID }) ?? attendees.first {
            return JVChatGeneralChange(
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
                department: department,
                knownArchived: knownArchived)
        }
        else {
            return self
        }
    }

    public func copy(relation: String, everybody: Bool) -> JVChatGeneralChange {
        guard attendees.count == 1 || everybody else { return self }

        return JVChatGeneralChange(
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
            department: department,
            knownArchived: knownArchived)
    }
    
    public func copy(receivedMessageID: Int? = nil, knownArchived: Bool? = nil) -> JVChatGeneralChange {
        return JVChatGeneralChange(
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
            receivedMessageID: receivedMessageID ?? self.receivedMessageID,
            unreadNumber: unreadNumber,
            lastActivityTimestamp: lastActivityTimestamp,
            hasActiveCall: hasActiveCall,
            department: department,
            knownArchived: knownArchived ?? self.knownArchived)
    }
    
    public func cachable() -> JVChatGeneralChange {
        return JVChatGeneralChange(
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
            department: department,
            knownArchived: knownArchived)
    }
    
    public func findAttendeeRelation(agentID: Int) -> String? {
        for attendee in attendees {
            guard attendee.ID == agentID else { continue }
            return attendee.relation
        }
        
        return nil
    }
}

public final class JVChatShortChange: JVBaseModelChange, NSCoding {
    public let ID: Int
    public let client: JVClientShortChange?
    public let attendee: JVChatAttendeeGeneralChange?
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
            client: JVClientShortChange(
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
        client: JVClientShortChange?,
        attendee: JVChatAttendeeGeneralChange?,
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
        client = coder.decodeObject(of: JVClientShortChange.self, forKey: codableClientKey)
        attendee = coder.decodeObject(of: JVChatAttendeeGeneralChange.self, forKey: codableAttendeeKey)
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
              isAssistant: Bool) -> JVChatShortChange {
        return JVChatShortChange(
            ID: ID,
            client: client,
            attendee: JVChatAttendeeGeneralChange(
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

public final class JVChatLastMessageChange: JVBaseModelChange {
    public let chatID: Int
    public let messageID: Int?
    public let messageLocalID: String?
    
    public override var primaryValue: Int {
        return chatID
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

public final class JVChatPreviewMessageChange: JVBaseModelChange {
    public let chatID: Int
    public let messageID: Int?
    public let messageLocalID: String?

    public override var primaryValue: Int {
        return chatID
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

public final class JVChatHistoryChange: JVBaseModelChange {
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

public final class JVChatIncrementUnreadChange: JVBaseModelChange {
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

public final class JVChatResetUnreadChange: JVBaseModelChange {
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

public final class JVChatTransferRequestChange: JVBaseModelChange {
    public let ID: Int
    public let agentID: Int?
    public let departmentID: Int?
    public let assisting: Bool
    public let comment: String?
    
    public override var primaryValue: Int {
        return ID
    }
    
    public init(ID: Int, agentID: Int?, departmentID: Int?, assisting: Bool, comment: String?) {
        self.ID = ID
        self.agentID = agentID
        self.departmentID = departmentID
        self.assisting = assisting
        self.comment = comment
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class JVChatTransferCompleteChange: JVBaseModelChange {
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

public final class JVChatTransferRejectChange: JVBaseModelChange {
    public enum Reason: String {
        case rejectByAgent = "target_agent_reject"
        case rejectByDepartment = "target_group_reject"
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

public final class JVChatTransferCancelChange: JVBaseModelChange {
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

public final class JVChatFinishedChange: JVBaseModelChange {
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

public final class JVChatRequestCancelledChange: JVBaseModelChange {
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

public final class JVChatRequestCancelChange: JVBaseModelChange {
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

public final class JVChatAcceptChange: JVBaseModelChange {
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

public final class JVChatAcceptFailChange: JVBaseModelChange {
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
        acceptedAgentID = json["accepted_agent_id"].intValue.jv_valuable
        reason = Reason(rawValue: json["reason"].stringValue) ?? .unknown
        super.init(json: json)
    }
}

public final class JVChatTerminationChange: JVBaseModelChange {
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

public final class JVChatDraftChange: JVBaseModelChange {
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

public final class JVSdkChatAgentsUpdateChange: JVBaseModelChange {
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

