//
//  ClientProactiveRule+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

extension ClientProactiveRule {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientProactiveRuleGeneralChange {
            _agent = context.agent(for: c.agentID, provideDefault: true)
            _date = c.date
            _text = c.text
        }
    }
}

public final class ClientProactiveRuleGeneralChange: BaseModelChange {
    public let agentID: Int
    public let date: Date
    public let text: String
    
    required public init( json: JsonElement) {
        agentID = json["agent_id"].intValue
        date = json["time"].string?.parseDateUsingFullFormat() ?? Date(timeIntervalSince1970: 0)
        text = json["invitation_text"].stringValue
        super.init(json: json)
    }
}
