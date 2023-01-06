//
//  JVMessageTransfer+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVMessageTransfer {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVMessageTransferGeneralChange {
            _agentID = c.agentID
            _comment = c.comment
        }
    }
}

public final class JVMessageTransferGeneralChange: JVBaseModelChange {
    public let agentID: Int
    public let comment: String?
    
    required public init( json: JsonElement) {
        agentID = json["agent_id"].intValue
        comment = json["text"].valuable
        super.init(json: json)
    }
}
