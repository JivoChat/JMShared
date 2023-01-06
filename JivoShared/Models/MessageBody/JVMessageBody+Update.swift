//
//  JVMessageBody+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVMessageBody {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVMessageBodyGeneralChange {
            _agent = c.agentID.flatMap { $0 > 0 ? context.agent(for: $0, provideDefault: true) : nil }
            _department = c.departmentID.flatMap { $0 > 0 ? context.department(for: $0) : nil }
            _to = c.to
            _from = c.from
            _subject = c.subject
            _text = c.text
            _event = c.event
            _phone = c.phone
            _email = c.email
            _endCallSide = c.endCallSide
            _callID = c.callID
            _type = c.type
            _reason = c.reason
            _recordLink = c.recordLink
            _taskID = c.taskID ?? 0
            _createdAt = c.createdTs.flatMap { Date(timeIntervalSince1970: $0) }
            _updatedAt = c.updatedTs.flatMap { Date(timeIntervalSince1970: $0) }
            _transitionedAt = c.transitionTs.flatMap { Date(timeIntervalSince1970: $0) }
            _notifyAt = c.notifyTs.flatMap { Date(timeIntervalSince1970: $0) }
            _status = c.status
            _taskStatus = c.taskStatus
            _buttons = c.buttons
            _orderID = c.orderID
        }
    }
}

public final class JVMessageBodyGeneralChange: JVBaseModelChange {
    public let agentID: Int?
    public let to: String?
    public let from: String?
    public let subject: String?
    public let text: String?
    public let event: String?
    public let phone: String?
    public let email: String?
    public let endCallSide: String?
    public let callID: String?
    public let type: String?
    public let reason: String?
    public let recordLink: String?
    public let taskID: Int?
    public let createdTs: TimeInterval?
    public let updatedTs: TimeInterval?
    public let transitionTs: TimeInterval?
    public let notifyTs: TimeInterval?
    public let status: String?
    public let taskStatus: String?
    public let buttons: String?
    public let orderID: String?
    public let departmentID: Int?

    required public init(json: JsonElement) {
        let call = json.has(key: "call") ?? json
        let task = json.has(key: "reminder") ?? json

        let callAgentID = call["agent_id"].int
        event = call["status"].string
        phone = (call["phone"].string ?? json["client_phone"].string)?.jv_valuable.flatMap { "+" + $0 }
        email = call["email"].string ?? json["client_email"].string
        endCallSide = call["end_call_side"].string
        callID = call["call_id"].string
        type = call["type"].string
        reason = call["reason"].string
        recordLink = call["record_url"].string

        to = json["to"].string
        from = json["from"].string
        subject = json["subject"].string

        let taskAgentID = task["agent_id"].int
        let taskText = task["text"].string
        taskID = task["reminder_id"].int
        createdTs = task["created_ts"].double
        updatedTs = task["updated_ts"].double
        transitionTs = task["transition_ts"].double
        notifyTs = task["notify_ts"].double
        status = json["status"].string
        taskStatus = task["status"].string

        let defaultAgentID = json["agent"].int ?? json["by_agent"].int
        agentID = callAgentID ?? taskAgentID ?? defaultAgentID
        departmentID = json["group"].int

        let defaultText = json["text"].string
        text = taskText ?? defaultText
        
        if let keyboard = json["keyboard"].array?.compactMap({ $0["text"].string }) {
            buttons = keyboard.isEmpty ? nil : keyboard.joined(separator: "\n")
        }
        else {
            buttons = nil
        }
        
        orderID = json["order_id"].string

        super.init(json: json)
    }
    
    public var isValidCall: Bool {
        guard let _ = callID else { return false }
        guard let _ = type else { return false }
        return true
    }
}
