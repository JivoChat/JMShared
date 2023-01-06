//
//  JVClientProactiveRule.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 18/07/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public final class JVClientProactiveRule: JVBaseModel {
    @objc dynamic public var _agent: JVAgent?
    @objc dynamic public var _date: Date?
    @objc dynamic public var _text: String = ""
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
