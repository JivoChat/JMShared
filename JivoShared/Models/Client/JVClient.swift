//
//  JVClient.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 11/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMRepicKit

public final class JVClient: JVBaseModel {
    @objc dynamic public var _ID: Int = 0
    @objc dynamic public var _publicID: String = ""
    @objc dynamic public var _guestID: String = ""
    @objc dynamic public var _chatID: Int = 0
    @objc dynamic public var _channelID: Int = 0
    @objc dynamic public var _channelName: String?
    @objc dynamic public var _channel: Channel?
    @objc dynamic public var _displayName = String()
    @objc dynamic public var _avatarLink: String?
    @objc dynamic public var _emailByClient: String?
    @objc dynamic public var _emailByAgent: String?
    @objc dynamic public var _phoneByClient: String?
    @objc dynamic public var _phoneByAgent: String?
    @objc dynamic public var _comment: String?
    @objc dynamic public var _visitsNumber: Int = 0
    @objc dynamic public var _assignedAgent: JVAgent?
    @objc dynamic public var _navigatesNumber: Int = 0
    @objc dynamic public var _activeSession: ClientSession?
    @objc dynamic public var _proactiveRule: ClientProactiveRule?
    @objc dynamic public var _integration: String?
    @objc dynamic public var _integrationLink: String?
    @objc dynamic public var _isOnline: Bool = true
    @objc dynamic public var _hasStartup: Bool = true
    @objc dynamic public var _hasActiveCall: Bool = false
    @objc dynamic public var _task: Task?
    @objc dynamic public var _isBlocked: Bool = false
    public let _customData = List<ClientCustomData>()

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
