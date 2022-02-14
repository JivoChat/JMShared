//  
//  JVCall+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVCall {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? CallGeneralChange {
            if _ID == 0 { _ID = c.ID }
        }
        else {
            abort()
        }
    }
}

public final class CallGeneralChange: BaseModelChange {
    public let ID: Int
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init(json: JsonElement) {
        ID = json["msg_id"].intValue
        super.init(json: json)
    }
}

public final class CallLiveChange: BaseModelChange {
    public let ID: String
    public let phone: String
    public let agentID: Int
    public let chatID: Int
    public let type: MessageBodyCallType
    public let clientID: Int
    public let channelId: Int?
    public let event: MessageBodyCallEvent
    public let clientConnected: Bool
    public let reason: String?

    required public init(json: JsonElement) {
        ID = json["call_id"].stringValue
        phone = json["phone"].stringValue
        agentID = json["agent_id"].intValue
        chatID = json["chat_id"].intValue
        type = MessageBodyCallType(rawValue: json["type"].stringValue) ?? .unknown
        clientID = json["client_id"].intValue
        channelId = json["widget_id"].int
        event = MessageBodyCallEvent(rawValue: json["status"].stringValue) ?? .unknown
        clientConnected = json["client_connected"].boolValue
        reason = json["reason"].string
        super.init(json: json)
    }
}
