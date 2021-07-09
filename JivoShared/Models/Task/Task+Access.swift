//
//  Task+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public enum TaskStatus: String {
    case unknown
    case active = "active"
    case fired = "fired"
    public var iconName: String? {
        switch self {
        case .unknown: return nil
        case .active: return "reminder_active"
        case .fired: return "reminder_fired"
        }
    }
}

extension Task {
    public var ID: Int {
        return _ID
    }
    public var siteID: Int {
        return _siteID
    }
    public var clientID: Int {
        return _clientID
    }
    public var agent: Agent? {
        return _agent
    }
    public var text: String? {
        return _text.valuable
    }
    public var notifyAt: Date {
        return Date(timeIntervalSince1970: _notifyTimestamp)
    }
    public var status: TaskStatus {
        return TaskStatus(rawValue: _status) ?? .unknown
    }
        public var iconName: String? {
        switch status {
        case .active: return "reminder_active"
        case .fired: return "reminder_fired"
        case .unknown: return nil
        }
    }
    
    public func convertToMessageBody() -> MessageBodyTask {
        return MessageBodyTask(
            taskID: _ID,
            agent: _agent,
            text: _text,
            createdAt: Date(timeIntervalSince1970: _createdTimestamp),
            updatedAt: Date(timeIntervalSince1970: _modifiedTimestamp),
            transitionedAt: Date(timeIntervalSince1970: _modifiedTimestamp),
            notifyAt: Date(timeIntervalSince1970: _notifyTimestamp),
            status: MessageBodyTaskStatus(rawValue: _status) ?? .fired
        )
    }}
