//
//  JVAgentRichStatus.swift
//  JMShared
//
//  Created by Yulia on 17.11.2022.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVAgentRichStatus: JVBaseModel {
    @objc dynamic public var _statusID: Int = 0
    @objc dynamic public var _title: String = ""
    @objc dynamic public var _emoji: String = ""
    @objc dynamic public var _position: Int = 0

    public override class func primaryKey() -> String? {
        "_statusID"
    }
    
    public override func apply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
