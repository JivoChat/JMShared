//  
//  JVCall.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVCall: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    
    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func apply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
