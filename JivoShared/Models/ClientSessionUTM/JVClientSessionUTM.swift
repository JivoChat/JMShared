//
//  JVClientSessionUTM.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public final class JVClientSessionUTM: JVBaseModel {
    @objc dynamic public var _source: String?
    @objc dynamic public var _keyword: String?
    @objc dynamic public var _campaign: String?
    @objc dynamic public var _medium: String?
    @objc dynamic public var _content: String?
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
