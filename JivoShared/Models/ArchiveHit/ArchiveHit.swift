//  
//  ArchiveHit.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JivoShared

public final class ArchiveHit: BaseModel {
    @objc dynamic public var _ID: String = ""
    @objc dynamic public var _score: Float = 0
    @objc dynamic public var _chatItem: ArchiveHitChatItem?
    @objc dynamic public var _callItem: ArchiveHitCallItem?
    @objc dynamic public var _latestActivityTime: Date?

    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
