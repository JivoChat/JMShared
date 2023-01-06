//  
//  JVArchiveHitCallItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVArchiveHitCallItem: JVArchiveHitItem {
    @objc dynamic public var _status: String = ""
    @objc dynamic public var _cost: Float = 0
    @objc dynamic public var _costCurrency: String = ""
    @objc dynamic public var _call: JVCall?

    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
    
    public override func recursiveDelete(context: JVIDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
}
