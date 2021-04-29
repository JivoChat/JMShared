//
//  MessageBody+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
public struct MessageBodyEmail {
    public let from: String
    public let to: String
    public let subject: String
}
public struct MessageBodyTransfer {
    public let agent: Agent?
}
public struct MessageBodyInvite {
    public let by: Agent?
    public let comment: String?
}

public struct MessageBodyCall {
    public let callID: String
    public let agent: Agent?
    public let type: MessageBodyCallType
    public let phone: String
    public let event: MessageBodyCallEvent
    public let endCallSide: MessageBodyCallEndCallSide?
    public let reason: MessageBodyCallReason?
    public let recordLink: String?

    public var recordURL: URL? {
        if let link = recordLink {
            return URL(string: link)
        }
        else {
            return nil
        }
    }

    public var isFailed: Bool {
        return (event == .error)
    }
}
public struct MessageBodyOrder {
    public let orderID: String
    public let email: String?
    public let phone: String?
    public let subject: String
    public let text: String
}
public enum MessageBodyCallType: String {
    case callback = "callback"
    case incoming = "incoming"
    case outgoing = "outgoing"
    case unknown
    
    public var isIncoming: Bool {
        switch self {
        case .callback: return false
        case .incoming: return true
        case .outgoing: return false
        case .unknown: return true
        }
    }
}
public enum MessageBodyCallEndCallSide: String {
    case from = "from"
    case to = "to"
}
public enum MessageBodyCallEvent: String {
    case start = "start"
    case agentConnecting = "agent_connecting"
    case agentConnected = "agent_connected"
    case agentDisconnected = "agent_disconnected"
    case clientConnected = "client_connected"
    case error = "error"
    case retry = "retry"
    case end = "end"
    case unknown
}
public enum MessageBodyCallReason: String {
    case isBusy = "is_busy"
    case allBusy = "all_busy"
    case invalidNumber = "invalid_number"
    case unknown
}

public struct MessageBodyReminder {
    public let reminderID: Int
    public let agent: Agent?
    public let text: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public let transitionedAt: Date?
    public let notifyAt: Date
    public let status: MessageBodyReminderStatus
}

public enum MessageBodyReminderStatus: String {
    case created = "created"
    case updated = "updated"
    case completed = "completed"
    case deleted = "deleted"
    case fired = "fired"
    case unknown

    public var isFinished: Bool {
        switch self {
        case .created: return false
        case .updated: return false
        case .completed: return true
        case .deleted: return true
        case .fired: return true
        case .unknown: return false
        }
    }
}

extension MessageBody {
    public var email: MessageBodyEmail? {
        guard let from = _from?.valuable else { return nil }
        guard let to = _to?.valuable else { return nil }

        return MessageBodyEmail(
            from: from,
            to: to,
            subject: _subject ?? String()
        )
    }
    
    public var transfer: MessageBodyTransfer? {
        guard let agent = _agent else { return nil }
        
        return MessageBodyTransfer(
            agent: agent
        )
    }
    
    public var invite: MessageBodyInvite? {
        return MessageBodyInvite(
            by: _agent,
            comment: _text
        )
    }
    
    public var call: MessageBodyCall? {
        guard let event = _event?.valuable else { return nil }
        guard let phone = _phone?.valuable else { return nil }
        guard let callID = _callID?.valuable else { return nil }
        guard let type = _type?.valuable else { return nil }
        
        return MessageBodyCall(
            callID: callID,
            agent: _agent,
            type: MessageBodyCallType(rawValue: type) ?? .unknown,
            phone: phone,
            event: MessageBodyCallEvent(rawValue: event) ?? .unknown,
            endCallSide: _endCallSide?.valuable.flatMap(MessageBodyCallEndCallSide.init),
            reason: _reason?.valuable.flatMap(MessageBodyCallReason.init),
            recordLink: _recordLink?.valuable
        )
    }

    public var reminder: MessageBodyReminder? {
        guard
            _reminderID > 0,
            let agent = _agent,
            let notifyAt = _notifyAt
        else { return nil }

        return MessageBodyReminder(
            reminderID: _reminderID,
            agent: agent,
            text: _text ?? String(),
            createdAt: _createdAt,
            updatedAt: _updatedAt,
            transitionedAt: _transitionedAt,
            notifyAt: notifyAt,
            status: _status.flatMap(MessageBodyReminderStatus.init) ?? .fired
        )
    }
    
    public var text: String? {
        return _text
    }
    
    public var buttons: [String] {
        return _buttons?.valuable?.components(separatedBy: "\n") ?? []
    }
    
    public var order: MessageBodyOrder? {
        guard
            let orderID = _orderID?.valuable,
            let subject = _subject?.valuable,
            let text = _text?.valuable
        else { return nil }
        
        return MessageBodyOrder(
            orderID: orderID,
            email: _email,
            phone: _phone,
            subject: subject,
            text: text)
    }
    
    public var status: String? {
        return _event
    }
}
