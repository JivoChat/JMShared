//
//  JVDepartment.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 10/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

open class JVDepartment: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _name: String = ""
    @objc dynamic public var _icon: String = ""
    @objc dynamic public var _brief: String = ""
    @objc dynamic public var _channelsIds: String = ""
    @objc dynamic public var _agentsIds: String = ""

    open override class func primaryKey() -> String? {
        return "_ID"
    }
    
    open override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    open override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
