//
//  JVMessageMedia.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19/10/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVMessageMedia: JVBaseModel {
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
    @objc dynamic public var _title: String?
    @objc dynamic public var _link: String?
    @objc dynamic public var _text: String?

    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
