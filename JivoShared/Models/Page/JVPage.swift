//  
//  JVPage.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVPage: JVBaseModel {
    @objc dynamic public var _URL: String = ""
    @objc dynamic public var _title: String = ""
    @objc dynamic public var _time: String?
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
