//
//  JVAgentStatus.swift
//  App
//
//  Created by Yulia on 01.12.2022.
//  Copyright © 2022 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVAgentStatus: JVBaseModel {
    @objc dynamic public var _agentID: Int = 0
    @objc dynamic public var _agentStatusID: Int = 0
    @objc dynamic public var _title: String = ""
    @objc dynamic public var _comment: String = ""
    @objc dynamic public var _emoji: String = ""
    @objc dynamic public var _position: Int = 0

    public override class func primaryKey() -> String? {
        "_agentID"
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
