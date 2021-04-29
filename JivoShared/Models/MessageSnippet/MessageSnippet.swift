//
//  MessageSnippet.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMShared

public final class MessageSnippet: BaseModel {
    @objc dynamic public var _URL: String?
    @objc dynamic public var _title: String = ""
    @objc dynamic public var _iconURL: String?
    @objc dynamic public var _HTML: String = ""
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
