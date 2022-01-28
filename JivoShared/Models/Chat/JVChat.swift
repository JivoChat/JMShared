//
//  JVChat.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 11/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVChat: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    public let _attendees = List<ChatAttendee>()
    public let _agents = List<JVAgent>()
    @objc dynamic public var _client: Client?
    @objc dynamic public var _owningAgent: JVAgent?
    @objc dynamic public var _lastMessage: JVMessage?
    @objc dynamic public var _lastMessageValid: Bool = true
    @objc dynamic public var _previewMessage: JVMessage?
    @objc dynamic public var _activeRing: JVMessage?
    @objc dynamic public var _attendee: ChatAttendee?
    @objc dynamic public var _isGroup: Bool = false
    @objc dynamic public var _isMain: Bool = false
    @objc dynamic public var _title: String?
    @objc dynamic public var _about: String?
    @objc dynamic public var _icon: String?
    @objc dynamic public var _loadedPartialHistory = false
    @objc dynamic public var _loadedEntireHistory = false
    @objc dynamic public var _unreadNumber: Int = -1
    @objc dynamic public var _transferCancelled: Bool = false
    @objc dynamic public var _transferTo: JVAgent?
    @objc dynamic public var _transferAssisting: Bool = false
    @objc dynamic public var _transferDate: Date?
    @objc dynamic public var _transferComment: String?
    @objc dynamic public var _transferFailReason: String?
    @objc dynamic public var _requestCancelledBySystem: Bool = false
    @objc dynamic public var _requestCancelledByAgent: JVAgent?
    @objc dynamic public var _terminationDate: Date?
    @objc dynamic public var _isArchived: Bool = false
    @objc dynamic public var _lastActivityTimestamp = TimeInterval(0)
    @objc dynamic public var _orderingBlock = Int(0)
    @objc dynamic public var _hasActiveCall: Bool = false
    @objc dynamic public var _department: String?
    @objc dynamic public var _draft: String?

    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
