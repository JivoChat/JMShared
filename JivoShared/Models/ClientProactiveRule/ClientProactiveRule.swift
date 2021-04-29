//
//  ClientProactiveRule.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 18/07/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

public final class ClientProactiveRule: BaseModel {
    @objc dynamic public var _agent: Agent?
    @objc dynamic public var _date: Date?
    @objc dynamic public var _text: String = ""
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
