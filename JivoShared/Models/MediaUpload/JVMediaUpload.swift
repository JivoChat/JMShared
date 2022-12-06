//  
//  JVMediaUpload.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVMediaUpload: JVBaseModel {
    @objc dynamic public var _ID: String = ""
    @objc dynamic public var _filePath: String = ""
    @objc dynamic public var _recipientType: String = ""
    @objc dynamic public var _recipientID: Int = 0
    @objc dynamic public var _chatID: Int = 0

    public override class func primaryKey() -> String? {
        return "_filePath"
    }
    
    public override func apply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
