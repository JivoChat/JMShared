//  
//  JVArchiveHit.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVArchiveHit: JVBaseModel {
    @objc dynamic public var _ID: String = ""
    @objc dynamic public var _score: Float = 0
    @objc dynamic public var _chatItem: JVArchiveHitChatItem?
    @objc dynamic public var _callItem: JVArchiveHitCallItem?
    @objc dynamic public var _latestActivityTime: Date?

    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func recursiveDelete(context: JVIDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
