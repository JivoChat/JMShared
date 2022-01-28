//
//  JVClientSessionGeo.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public final class JVClientSessionGeo: JVBaseModel {
    @objc dynamic public var _country: String?
    @objc dynamic public var _region: String?
    @objc dynamic public var _city: String?
    @objc dynamic public var _organization: String?
    @objc dynamic public var _countryCode: String?
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
