//
//  _JVAgentRichStatus+Update.swift
//  JMShared
//
//  Created by Yulia on 17.11.2022.
//

import Foundation
import JMCodingKit

extension _JVAgentRichStatus {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVAgentRichStatusGeneralChange {
            if _statusID == 0 { _statusID = c.statusID }
            _title = c.title
            _emoji = c.emoji
            _position = (c.position > 0 ? c.position : _position)
        }
    }
}

public final class JVAgentRichStatusGeneralChange: JVBaseModelChange, Codable {
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
