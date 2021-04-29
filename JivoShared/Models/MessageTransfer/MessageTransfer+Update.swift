//
//  MessageTransfer+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

extension MessageTransfer {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? MessageTransferGeneralChange {
            _agentID = c.agentID
            _comment = c.comment
        }
    }
}

public final class MessageTransferGeneralChange: BaseModelChange {
    public let agentID: Int
    public let comment: String?
    
    required public init( json: JsonElement) {
        agentID = json["agent_id"].intValue
        comment = json["text"].valuable
        super.init(json: json)
    }
}
