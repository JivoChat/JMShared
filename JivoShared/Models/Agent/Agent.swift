//
//  Agent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 10/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMShared
open class Agent: BaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _publicID: String = ""
    @objc dynamic public var _email: String = ""
    @objc dynamic public var _phone: String = ""
    @objc dynamic public var _stateID: Int = 0
    @objc dynamic public var _avatarLink: String?
    @objc dynamic public var _displayName: String = ""
    @objc dynamic public var _title: String = ""
    @objc dynamic public var _isOwner: Bool = false
    @objc dynamic public var _isAdmin: Bool = true
    @objc dynamic public var _isOperator: Bool = true
    @objc dynamic public var _callingDestination: Int = 0
    @objc dynamic public var _callingOptions: Int = 0
    @objc dynamic public var _isWorking: Bool = true
    @objc dynamic public var _session: AgentSession?
    @objc dynamic public var _worktime: Worktime?
    @objc dynamic public var _hasSession: Bool = false
    @objc dynamic public var _lastMessageDate: Date?
    @objc dynamic public var _lastMessage: Message?
    @objc dynamic public var _chat: Chat?
    @objc dynamic public var _orderingUnread: Bool = false
    @objc dynamic public var _orderingGroup: Int = 0
    @objc dynamic public var _orderingName: String? = nil
    @objc dynamic public var _draft: String?

    open override class func primaryKey() -> String? {
        return "_ID"
    }
    
    open override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    open override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
