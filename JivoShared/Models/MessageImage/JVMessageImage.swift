//
//  _JVMessageImage.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class _JVMessageImage: JVBaseModel {
    @objc dynamic public var _fileName: String = ""
    @objc dynamic public var _URL: String = ""
    @objc dynamic public var _uploadTS: Int = 0
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
