//
//  MessageMedia.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19/10/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMShared

public final class MessageMedia: BaseModel {
    @objc dynamic public var _type: String = ""
    @objc dynamic public var _mime: String = ""
    @objc dynamic public var _thumbLink: String = ""
    @objc dynamic public var _fullLink: String = ""
    @objc dynamic public var _emoji: String = ""
    @objc dynamic public var _name: String = ""
    @objc dynamic public var _size: Int = 0
    @objc dynamic public var _width: Int = 0
    @objc dynamic public var _height: Int = 0
    @objc dynamic public var _duration: Int = 0
    @objc dynamic public var _latitude: Double = 0
    @objc dynamic public var _longitude: Double = 0
    @objc dynamic public var _phone: String = ""

    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
