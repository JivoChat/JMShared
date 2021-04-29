//  
//  ArchiveHitItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMShared
open class ArchiveHitItem: BaseModel {
    @objc dynamic public var _ID: String = UUID().uuidString
    @objc dynamic public var _type: String = ""
    @objc dynamic public var _responseTimeout: Int = 0
    @objc dynamic public var _duration: Int = 0
    @objc dynamic public var _eventsNumber: Int = 0
    @objc dynamic public var _latestChatID: Int = 0
    @objc dynamic public var _chat: Chat?
    public let _agents = List<Agent>()
    
    open override class func primaryKey() -> String? {
        return "_ID"
    }
}
