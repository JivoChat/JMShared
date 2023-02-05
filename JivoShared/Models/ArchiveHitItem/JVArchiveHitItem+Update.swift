//  
//  _JVArchiveHitItem+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension _JVArchiveHitItem {
}

open class JVArchiveHitItemGeneralChange: JVBaseModelChange {
    public let ID: String
    public let responseTimeout: Int
    public let duration: Int
    public let eventsNumber: Int
    public let agentIDs: [Int]
    public let latestChatID: Int
    public let chatChange: JVChatGeneralChange?
    
    public init(ID: String,
         responseTimeout: Int,
         duration: Int,
         eventsNumber: Int,
         agentIDs: [Int],
         latestChatID: Int,
         chatChange: JVChatGeneralChange?) {
        self.ID = ID
        self.responseTimeout = responseTimeout
        self.duration = duration
        self.eventsNumber = eventsNumber
        self.agentIDs = agentIDs
        self.latestChatID = latestChatID
        self.chatChange = chatChange
        super.init()
    }
    
    required public init(json: JsonElement) {
        ID = UUID().uuidString
        responseTimeout = json["response_timeout_sec"].intValue
        duration = json["duration_sec"].intValue
        eventsNumber = json["events_count"].intValue
        agentIDs = json["agent_ids"].intArray ?? []
        latestChatID = json["latest_chat_id"].intValue
        chatChange = json["chat"].parse()
        super.init(json: json)
    }
}
