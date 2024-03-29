//  
//  JVArchiveHitCallItem+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVArchiveHitCallItem {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVArchiveHitCallItemGeneralChange {
            _ID = c.ID
            _type = c.type
            _status = c.status
            _responseTimeout = c.responseTimeout
            _duration = c.duration
            _eventsNumber = c.eventsNumber
            _cost = c.cost
            _costCurrency = c.costCurrency
            _agents.jv_set(c.agentIDs.compactMap { context.object(JVAgent.self, primaryKey: $0) })
            _latestChatID = c.latestChatID
            _chat = context.upsert(of: JVChat.self, with: c.chatChange?.copy(knownArchived: true))
            _call = context.upsert(of: JVCall.self, with: c.callChange)
        }
    }
    
    public func performDelete(inside context: JVIDatabaseContext) {
        context.customRemove(objects: [_chat].jv_flatten(), recursive: true)
    }
}

public final class JVArchiveHitCallItemGeneralChange: JVArchiveHitItemGeneralChange {
    public let type: String
    public let status: String
    public let cost: Float
    public let costCurrency: String
    public let callChange: JVCallGeneralChange?
    
    public init(ID: String,
         responseTimeout: Int,
         duration: Int,
         eventsNumber: Int,
         agentIDs: [Int],
         latestChatID: Int,
         chatChange: JVChatGeneralChange?,
         type: String,
         status: String,
         cost: Float,
         costCurrency: String,
         callChange: JVCallGeneralChange?) {
        self.type = type
        self.status = status
        self.cost = cost
        self.costCurrency = costCurrency
        self.callChange = callChange
        
        super.init(
            ID: ID,
            responseTimeout: responseTimeout,
            duration: duration,
            eventsNumber: eventsNumber,
            agentIDs: agentIDs,
            latestChatID: latestChatID,
            chatChange: chatChange
        )
    }
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    required public init( json: JsonElement) {
        type = json["call_type"].stringValue
        status = json["call_status"].stringValue
        cost = json["cost"].floatValue
        costCurrency = json["cost_currency"].stringValue
        callChange = json["call"].parse()
        super.init(json: json)
    }
    
    public func copyUnrelative() -> JVArchiveHitCallItemGeneralChange {
        return JVArchiveHitCallItemGeneralChange(
            ID: ID,
            responseTimeout: responseTimeout,
            duration: duration,
            eventsNumber: eventsNumber,
            agentIDs: agentIDs,
            latestChatID: latestChatID,
            chatChange: chatChange?.copy(relation: "", everybody: true),
            type: type,
            status: status,
            cost: cost,
            costCurrency: costCurrency,
            callChange: callChange
        )
    }
}
