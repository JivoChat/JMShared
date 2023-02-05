//
//  _JVChatAttendee+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public enum JVChatAttendeeNotifying: Int {
    case nothing = 0
    case everything = 1
    case mentions = 2
    
    public static var allCases: [JVChatAttendeeNotifying] {
        return [.everything, .nothing, .mentions]
    }
}

public enum _JVChatAttendeeRelation: Equatable {
    case invitedBySystem
    case invitedByAgent(_JVAgent, toAssist: Bool, comment: String?)
    case attendee(agent: _JVAgent?, toAssist: Bool, comment: String?)
    case team
        public var code: String {
        switch self {
        case .invitedBySystem: return "invited"
        case .invitedByAgent: return "invited"
        case .attendee: return "attendee"
        case .team: return ""
        }
    }
        public var isInvited: Bool {
        switch self {
        case .invitedBySystem: return true
        case .invitedByAgent: return true
        case .attendee: return false
        case .team: return false
        }
    }
}

extension _JVChatAttendee {
    public var agent: _JVAgent? {
        return _agent
    }
    
    public var relation: _JVChatAttendeeRelation {
        if _relation == "invited" {
            if let agent = _invitedBy {
                return .invitedByAgent(agent, toAssist: _toAssist, comment: _comment)
            }
            else {
                return .invitedBySystem
            }
        }
        else if _relation == "attendee" {
            return .attendee(agent: _invitedBy, toAssist: _toAssist, comment: _comment)
        }
        else {
            return .team
        }
    }
    
    public var comment: String? {
        return _comment
    }
    
    public var invitedBy: _JVAgent? {
        return _invitedBy
    }
    
    public var isAssistant: Bool {
        return _toAssist
    }
    
    public var receivedMessageID: Int? {
        if _receivedMessageID > 0 {
            return _receivedMessageID
        }
        else {
            return nil
        }
    }
    
    public var unreadNumber: Int? {
        if _unreadNumber > 0 {
            return _unreadNumber
        }
        else {
            return nil
        }
    }
    
    public var notifying: JVChatAttendeeNotifying? {
        return JVChatAttendeeNotifying(rawValue: _notifications)
    }
    
    public func export() -> JVChatAttendeeGeneralChange {
        return JVChatAttendeeGeneralChange(
            ID: _agent?.ID ?? 0,
            relation: _relation,
            comment: _comment,
            invitedBy: _invitedBy?.ID,
            isAssistant: _toAssist,
            receivedMessageID: _receivedMessageID,
            unreadNumber: _unreadNumber,
            notifications: _notifications)
    }
}
