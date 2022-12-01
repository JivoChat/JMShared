//
//  JVAgentStatus+Update.swift
//  JMShared
//
//  Created by Yulia on 01.12.2022.
//

import Foundation
import JMCodingKit

extension JVAgentStatus {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? AgentStatusChange {
            if _agentID == 0 { _agentID = c.agentID }
            _agentStatusID = c.agentStatusID
            _title = c.title
            _comment = c.comment
            _emoji = c.emoji
        }
    }
}

public final class AgentStatusChange: BaseModelChange, Codable {
    public let agentID: Int
    public let agentStatusID: Int
    public let title: String
    public let comment: String
    public let emoji: String
    
    public override var primaryValue: Int {
        return agentID
    }
    
    public override var isValid: Bool {
        return (agentID > 0)
    }
    
    required public init(json: JsonElement) {
        agentID = json["agent_id"].intValue
        agentStatusID = json["agent_status"]["agent_status_id"].intValue
        title = json["agent_status"]["title"].stringValue
        comment = json["agent_status"]["comment"].stringValue
        emoji = json["agent_status"]["emoji"].stringValue
        super.init(json: json)
    }
}
