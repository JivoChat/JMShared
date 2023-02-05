//
//  _JVClientCustomData.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public final class _JVClientCustomData: JVBaseModel {
    @objc dynamic public var _title: String?
    @objc dynamic public var _key: String?
    @objc dynamic public var _content: String = ""
    @objc dynamic public var _link: String?
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
