//  
//  JVTimezone.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class _JVTimezone: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _identifier: String?
    @objc dynamic public var _displayGMT: String?
    @objc dynamic public var _displayNameEn: String?
    @objc dynamic public var _displayNameRu: String?
    @objc dynamic public var _sortingOffset: Int = 0
    @objc dynamic public var _sortingRegionEn: String?
    @objc dynamic public var _sortingRegionRu: String?

    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
