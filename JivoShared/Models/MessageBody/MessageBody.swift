//
//  MessageBody.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/03/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import CoreLocation
import JMShared

public final class MessageBody: BaseModel {
    @objc dynamic public var _agent: Agent?
    @objc dynamic public var _to: String?
    @objc dynamic public var _from: String?
    @objc dynamic public var _subject: String?
    @objc dynamic public var _text: String?
    @objc dynamic public var _event: String?
    @objc dynamic public var _phone: String?
    @objc dynamic public var _email: String?
    @objc dynamic public var _endCallSide: String?
    @objc dynamic public var _callID: String?
    @objc dynamic public var _type: String?
    @objc dynamic public var _reason: String?
    @objc dynamic public var _recordLink: String?
    @objc dynamic public var _taskID: Int = 0
    @objc dynamic public var _createdAt: Date?
    @objc dynamic public var _updatedAt: Date?
    @objc dynamic public var _transitionedAt: Date?
    @objc dynamic public var _notifyAt: Date?
    @objc dynamic public var _status: String?
    @objc dynamic public var _buttons: String?
    @objc dynamic public var _orderID: String?

    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
