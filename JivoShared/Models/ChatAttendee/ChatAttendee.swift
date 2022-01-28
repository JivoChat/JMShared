//
//  ChatAttendee.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public final class ChatAttendee: JVBaseModel {
    @objc dynamic public var _agent: Agent?
    @objc dynamic public var _relation: String?
    @objc dynamic public var _comment: String?
    @objc dynamic public var _invitedBy: Agent?
    @objc dynamic public var _toAssist: Bool = false
    @objc dynamic public var _receivedMessageID: Int = 0
    @objc dynamic public var _unreadNumber: Int = 0
    @objc dynamic public var _notifications: Int = -1
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
