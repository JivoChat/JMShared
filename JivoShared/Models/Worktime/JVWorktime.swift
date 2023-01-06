//  
//  JVWorktime.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVWorktime: JVBaseModel {
    @objc dynamic public var _agentID: Int = 0
    @objc dynamic public var _timezoneID: Int = 0
    @objc dynamic public var _timezone: JVTimezone?
    @objc dynamic public var _enabled: Bool = false
    @objc dynamic public var _monConfig: Int64 = 0
    @objc dynamic public var _tueConfig: Int64 = 0
    @objc dynamic public var _wedConfig: Int64 = 0
    @objc dynamic public var _thuConfig: Int64 = 0
    @objc dynamic public var _friConfig: Int64 = 0
    @objc dynamic public var _satConfig: Int64 = 0
    @objc dynamic public var _sunConfig: Int64 = 0
    @objc dynamic public var _isDirty: Bool = false
    @objc dynamic public var _lastUpdate: Date?

    public override class func primaryKey() -> String? {
        return "_agentID"
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
