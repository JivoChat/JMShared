//  
//  JVArchiveHit+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVArchiveHit {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVArchiveHitGeneralChange {
            if _ID == "" { _ID = c.ID }
            _score = c.score
            _chatItem = context.upsert(of: JVArchiveHitChatItem.self, with: c.chatItem)
            _callItem = context.upsert(of: JVArchiveHitCallItem.self, with: c.callItem)
            _latestActivityTime = (_chatItem ?? _callItem)?.chat?.lastMessage?.date
        }
    }
    
    public func performDelete(inside context: JVIDatabaseContext) {
        context.customRemove(objects: [_chatItem, _callItem].jv_flatten(), recursive: true)
    }
}

public final class JVArchiveHitGeneralChange: JVBaseModelChange {
    public let ID: String
    public let score: Float
    public let chatItem: JVArchiveHitChatItemGeneralChange?
    public let callItem: JVArchiveHitCallItemGeneralChange?
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public override var isValid: Bool {
        if let item = chatItem, let change = item.chatChange, change.attendees.isEmpty { return true }
        if let _ = callItem { return true }
        return false
    }
    
    public init(ID: String,
         score: Float,
         chatItem: JVArchiveHitChatItemGeneralChange?,
         callItem: JVArchiveHitCallItemGeneralChange?) {
        self.ID = ID
        self.score = score
        self.chatItem = chatItem
        self.callItem = callItem
        super.init()
    }
    
    required public init( json: JsonElement) {
        ID = json["id"].stringValue
        score = json["score"].floatValue
        
        switch json["type"].stringValue {
        case "chat":
            chatItem = json["item"].parse()
            callItem = nil
            
        case "call":
            chatItem = nil
            callItem = json["item"].parse()
            
        default:
            chatItem = nil
            callItem = nil
        }
        
        super.init(json: json)
    }
    
    public func copyUnrelative() -> JVArchiveHitGeneralChange {
        return JVArchiveHitGeneralChange(
            ID: ID,
            score: score,
            chatItem: chatItem?.copyUnrelative(),
            callItem: callItem?.copyUnrelative()
        )
    }
}
