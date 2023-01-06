//
//  JVBot.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 10/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

open class JVBot: JVBaseModel {
    @objc dynamic public var _id: Int = 0
    @objc dynamic public var _avatarLink: String?
    @objc dynamic public var _displayName: String = ""
    @objc dynamic public var _title: String = ""

    open override class func primaryKey() -> String? {
        return "_id"
    }
    
    open override func recursiveDelete(context: JVIDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    open override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
