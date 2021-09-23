//
//  ChatAttendee+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension ChatAttendee {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ChatAttendeeGeneralChange {
            _agent = context.agent(for: c.ID, provideDefault: true)
            _relation = c.relation
            _comment = c.comment
            _invitedBy = c.invitedBy.flatMap { $0 > 0 ? context.agent(for: $0, provideDefault: true) : nil }
            _toAssist = c.isAssistant
            _receivedMessageID = c.receivedMessageID ?? 0
            _unreadNumber = c.unreadNumber ?? 0
            _notifications = c.notifications ?? _notifications
        }
        else if let _ = change as? ChatAttendeeAcceptChange {
            _relation = "attendee"
        }
        else if let c = change as? ChatAttendeeNotificationsChange {
            _notifications = c.notifications
        }
        else if let c = change as? ChatAttendeeResetUnreadChange {
            _receivedMessageID = c.messageID
            _unreadNumber = 0
        }
    }
}

public final class ChatAttendeeGeneralChange: BaseModelChange, NSCoding {
    public let ID: Int
    public let relation: String?
    public let comment: String?
    public let invitedBy: Int?
    public let isAssistant: Bool
    public let receivedMessageID: Int?
    public let unreadNumber: Int?
    public let notifications: Int?
    
    private let codableIdKey = "id"
    private let codableRelationKey = "relation"
    private let codableCommentKey = "comment"
    private let codableInviterKey = "inviter"
    private let codableAssistingKey = "assisting"
    private let codableReceivedKey = "received"
    private let codableUnreadKey = "unread"
    private let codableNotificationsKey = "notifications"
        public init(ID: Int,
         relation: String?,
         comment: String?,
         invitedBy: Int?,
         isAssistant: Bool,
         receivedMessageID: Int?,
         unreadNumber: Int?,
         notifications: Int?) {
        self.ID = ID
        self.relation = relation
        self.comment = comment
        self.invitedBy = invitedBy
        self.isAssistant = isAssistant
        self.receivedMessageID = receivedMessageID
        self.unreadNumber = unreadNumber
        self.notifications = notifications
        super.init()
    }
    
    required public init( json: JsonElement) {
        ID = json["agent_id"].intValue
        relation = json["rel"].valuable
        comment = json["comment"].valuable
        invitedBy = (json["by"].intValue > 0 ? json["by"].int : nil)
        isAssistant = json["assistant"].boolValue
        receivedMessageID = json["received_msg_id"].int
        unreadNumber = json["unread_number"].int
        notifications = json["notifications"].int
        super.init(json: json)
    }
    
    public init?(coder: NSCoder) {
        ID = coder.decodeInteger(forKey: codableIdKey)
        relation = coder.decodeObject(forKey: codableRelationKey) as? String
        comment = coder.decodeObject(forKey: codableCommentKey) as? String
        invitedBy = coder.decodeObject(forKey: codableInviterKey) as? Int
        isAssistant = coder.decodeBool(forKey: codableAssistingKey)
        receivedMessageID = coder.decodeObject(forKey: codableReceivedKey) as? Int
        unreadNumber = coder.decodeObject(forKey: codableUnreadKey) as? Int
        notifications = coder.decodeObject(forKey: codableNotificationsKey) as? Int
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ID, forKey: codableIdKey)
        coder.encode(relation, forKey: codableRelationKey)
        coder.encode(comment, forKey: codableCommentKey)
        coder.encode(invitedBy, forKey: codableInviterKey)
        coder.encode(isAssistant, forKey: codableAssistingKey)
        coder.encode(receivedMessageID, forKey: codableReceivedKey)
        coder.encode(unreadNumber, forKey: codableUnreadKey)
        coder.encode(notifications, forKey: codableNotificationsKey)
    }
    
    public func copy(relation: String) -> ChatAttendeeGeneralChange {
        return ChatAttendeeGeneralChange(
            ID: ID,
            relation: relation,
            comment: comment,
            invitedBy: invitedBy,
            isAssistant: isAssistant,
            receivedMessageID: receivedMessageID,
            unreadNumber: unreadNumber,
            notifications: notifications
        )
    }
    
    public func cachable() -> ChatAttendeeGeneralChange {
        return ChatAttendeeGeneralChange(
            ID: ID,
            relation: relation,
            comment: comment,
            invitedBy: invitedBy,
            isAssistant: isAssistant,
            receivedMessageID: 0,
            unreadNumber: 0,
            notifications: notifications
        )
    }
}

public final class ChatAttendeeAcceptChange: BaseModelChange {
}

public final class ChatAttendeeResetUnreadChange: BaseModelChange {
    public let ID: Int
    public let messageID: Int
        public init(ID: Int, messageID: Int) {
        self.ID = ID
        self.messageID = messageID
        super.init()
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}

public final class ChatAttendeeNotificationsChange: BaseModelChange {
    public let ID: Int
    public let notifications: Int
        public init(ID: Int, notifications: Int) {
        self.ID = ID
        self.notifications = notifications
        super.init()
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}

public func ==(lhs: ChatAttendeeRelation, rhs: ChatAttendeeRelation) -> Bool {
    if case .invitedBySystem = lhs, case .invitedBySystem = rhs {
        return true
    }
    else if case let .invitedByAgent(f1, f2, f3) = lhs, case let .invitedByAgent(s1, s2, s3) = rhs {
        return (f1 == s1 && f2 == s2 && f3 == s3)
    }
    else if case .attendee = lhs, case .attendee = rhs {
        return true
    }
    else if case .team = lhs, case .team = rhs {
        return true
    }
    else {
        return false
    }
}
