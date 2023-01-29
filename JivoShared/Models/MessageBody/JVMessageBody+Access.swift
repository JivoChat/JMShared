//
//  JVMessageBody+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public struct JVMessageBodyEmail {
    public let from: String
    public let to: String
    public let subject: String
}

public struct JVMessageBodyTransfer {
    public let agent: JVAgent?
    public let department: JVDepartment?
}

public struct JVMessageBodyInvite {
    public let by: JVAgent?
    public let comment: String?
}

public struct JVMessageBodyCall {
    public let callID: String
    public let agent: JVAgent?
    public let type: JVMessageBodyCallType
    public let phone: String?
    public let event: JVMessageBodyCallEvent
    public let endCallSide: JVMessageBodyCallEndCallSide?
    public let reason: JVMessageBodyCallReason?
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

public struct JVMessageBodyOrder {
    public let orderID: String
    public let email: String?
    public let phone: String?
    public let subject: String
    public let text: String
}

public enum JVMessageBodyCallType: String {
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

public enum JVMessageBodyCallEndCallSide: String {
    case from = "from"
    case to = "to"
}

public enum JVMessageBodyCallEvent: String {
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

public enum JVMessageBodyCallReason: String {
    case isBusy = "is_busy"
    case allBusy = "all_busy"
    case invalidNumber = "invalid_number"
    case unknown
}

public struct JVMessageBodyTask {
    public let taskID: Int
    public let agent: JVAgent?
    public let text: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public let transitionedAt: Date?
    public let notifyAt: Date
    public let status: JVMessageBodyTaskStatus
}

public struct JVMessageBodyConference {
    public let url: URL?
    public let title: String
}

public struct JVMessageBodyStory {
    public let text: String
    public let fileName: String
    public let thumb: URL?
    public let file: URL?
    public let title: String
}

public enum JVMessageBodyContactFormStatus: String {
    case inactive = "inactive"
    case editable = "editable"
    case syncing = "syncing"
    case snapshot = "snapshot"
}

public enum JVMessageBodyTaskStatus: String {
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

extension JVMessageBody {
    public var email: JVMessageBodyEmail? {
        guard let from = _from?.jv_valuable else { return nil }
        guard let to = _to?.jv_valuable else { return nil }

        return JVMessageBodyEmail(
            from: from,
            to: to,
            subject: _subject ?? String()
        )
    }
    
    public var transfer: JVMessageBodyTransfer? {
        guard _agent != nil || _department != nil
        else {
            return nil
        }
        
        return JVMessageBodyTransfer(
            agent: _agent,
            department: _department
        )
    }
    
    public var invite: JVMessageBodyInvite? {
        return JVMessageBodyInvite(
            by: _agent,
            comment: _text
        )
    }
    
    public var call: JVMessageBodyCall? {
        guard let event = _event?.jv_valuable else { return nil }
        guard let callID = _callID?.jv_valuable else { return nil }
        guard let type = _type?.jv_valuable else { return nil }
        
        return JVMessageBodyCall(
            callID: callID,
            agent: _agent,
            type: JVMessageBodyCallType(rawValue: type) ?? .unknown,
            phone: _phone?.jv_valuable,
            event: JVMessageBodyCallEvent(rawValue: event) ?? .unknown,
            endCallSide: _endCallSide?.jv_valuable.flatMap(JVMessageBodyCallEndCallSide.init),
            reason: _reason?.jv_valuable.flatMap(JVMessageBodyCallReason.init),
            recordLink: _recordLink?.jv_valuable
        )
    }

    public var task: JVMessageBodyTask? {
        guard
            _taskID > 0,
            let agent = _agent,
            let notifyAt = _notifyAt
        else { return nil }

        return JVMessageBodyTask(
            taskID: _taskID,
            agent: agent,
            text: _text ?? String(),
            createdAt: _createdAt,
            updatedAt: _updatedAt,
            transitionedAt: _transitionedAt,
            notifyAt: notifyAt,
            status: _status.flatMap(JVMessageBodyTaskStatus.init) ?? .fired
        )
    }
    
    public var text: String? {
        return _text
    }
    
    public var buttons: [String] {
        return _buttons?.jv_valuable?.components(separatedBy: "\n") ?? []
    }
    
    public var order: JVMessageBodyOrder? {
        guard
            let orderID = _orderID?.jv_valuable,
            let subject = _subject?.jv_valuable,
            let text = _text?.jv_valuable
        else { return nil }
        
        return JVMessageBodyOrder(
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
