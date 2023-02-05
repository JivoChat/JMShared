//
//  _JVChannel.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 11/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class _JVChannel: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _publicID: String = ""
    @objc dynamic public var _stateID: Int = 0
    @objc dynamic public var _siteURL: String = ""
    @objc dynamic public var _guestsNumber: Int = 0
    @objc dynamic public var _jointType: String = ""
    @objc dynamic public var _agentIDs: String = ""

    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
