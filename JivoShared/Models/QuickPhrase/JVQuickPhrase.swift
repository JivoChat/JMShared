//  
//  _JVQuickPhrase.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class _JVQuickPhrase: JVBaseModel {
    @objc dynamic public var _ID: String = ""
    @objc dynamic public var _lang: String = ""
    @objc dynamic public var _tags: String = ""
    @objc dynamic public var _text: String = ""
    @objc dynamic public var _isStandard: Bool = false
    
    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
