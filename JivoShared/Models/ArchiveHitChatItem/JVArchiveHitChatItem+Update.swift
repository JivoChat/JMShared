//  
//  JVArchiveHitChatItem+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVArchiveHitChatItem {
    public func performApply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVArchiveHitChatItemGeneralChange {
            _ID = c.ID
            _type = c.type
            _responseTimeout = c.responseTimeout
            _duration = c.duration
            _eventsNumber = c.eventsNumber
            _agents.set(c.agentIDs.compactMap { context.object(JVAgent.self, primaryKey: $0) })
            _latestChatID = c.latestChatID
            _chat = context.upsert(of: JVChat.self, with: c.chatChange?.copy(knownArchived: true))
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: [_chat].flatten(), recursive: true)
    }
}

public final class JVArchiveHitChatItemGeneralChange: JVArchiveHitItemGeneralChange {
    public let type: String
    
    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: ID)
    }
        public init(ID: String,
         responseTimeout: Int,
         duration: Int,
         eventsNumber: Int,
         agentIDs: [Int],
         latestChatID: Int,
         chatChange: JVChatGeneralChange?,
         type: String) {
        self.type = type
        
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
    
    required public init( json: JsonElement) {
        type = json["chat_type"].stringValue
        super.init(json: json)
    }
    
    public func copyUnrelative() -> JVArchiveHitChatItemGeneralChange {
        return JVArchiveHitChatItemGeneralChange(
            ID: ID,
            responseTimeout: responseTimeout,
            duration: duration,
            eventsNumber: eventsNumber,
            agentIDs: agentIDs,
            latestChatID: latestChatID,
            chatChange: chatChange?.copy(relation: "", everybody: true),
            type: type
        )
    }
}
