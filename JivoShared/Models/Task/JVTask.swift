//
// Created by Stan Potemkin on 2019-03-12.
// Copyright (c) 2019 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMRepicKit

public final class _JVTask: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _siteID: Int = 0
    @objc dynamic public var _clientID: Int = 0
    @objc dynamic public var _client: _JVClient?
    @objc dynamic public var _agent: _JVAgent?
    @objc dynamic public var _text: String = ""
    @objc dynamic public var _createdTimestamp: TimeInterval = 0
    @objc dynamic public var _modifiedTimestamp: TimeInterval = 0
    @objc dynamic public var _notifyTimestamp: TimeInterval = 0
    @objc dynamic public var _status: String = ""

    public override class func primaryKey() -> String? {
        return "_ID"
    }

    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
