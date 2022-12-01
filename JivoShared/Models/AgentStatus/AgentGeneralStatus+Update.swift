//
//  AgentRichStatus+Update.swift
//  JMShared
//
//  Created by Yulia on 17.11.2022.
//

import Foundation
import JMCodingKit

extension JVAgentGeneralStatus {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        
        if let c = change as? AgentGeneralStatusChange {
            if _statusID == 0 { _statusID = c.statusID }
            _title = c.title
            _emoji = c.emoji
            _position = c.position
        }
    }
}

public final class AgentGeneralStatusChange: BaseModelChange, Codable {
    public let statusID: Int
    public let title: String
    public let emoji: String
    public let position: Int
    
    public override var primaryValue: Int {
        return statusID
    }
    
    public override var isValid: Bool {
        return (statusID > 0)
    }
    
    required public init(json: JsonElement) {
        statusID = json["agent_status_id"].intValue
        title = json["title"].stringValue
        position = json["position"].intValue
        emoji = json["emoji"].stringValue
        super.init(json: json)
    }
}
