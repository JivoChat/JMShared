//
//  AgentSession.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import AVFoundation

open class AgentSession: JVBaseModel {
    @objc dynamic public var _sessionID: String = ""
    @objc dynamic public var _email: String = ""
    @objc dynamic public var _siteID: Int = 0
    @objc dynamic public var _isAdmin: Bool = false
    @objc dynamic public var _isOperator: Bool = true
    @objc dynamic public var _globalReceived: Bool = false
    @objc dynamic public var _globalGuestsInsightEnabled: Bool = true
    @objc dynamic public var _globalFileSizeLimit: Int = 0
    @objc dynamic public var _globalDisableArchiveForRegular: Bool = false
    @objc dynamic public var _globalPlatformTelephonyEnabled: Bool = false
    @objc dynamic public var _globalLimitedCRM: Bool = true
    @objc dynamic public var _globalAssignedAgentEnabled: Bool = true
    @objc dynamic public var _globalMessageEditingEnabled: Bool = true
    @objc dynamic public var _globalGroupsEnabled: Bool = true
    @objc dynamic public var _globalMentionsEnabled: Bool = true
    @objc dynamic public var _globalCommentsEnabled: Bool = true
    @objc dynamic public var _globalReactionsEnabled: Bool = true
    @objc dynamic public var _globalBusinessChatEnabled: Bool = true
    @objc dynamic public var _globalBillingUpdateEnabled: Bool = true
    @objc dynamic public var _globalStandaloneTasksEnabled: Bool = true
    @objc dynamic public var _globalFeedbackSdkEnabled: Bool = true
    @objc dynamic public var _globalMediaServiceEnabled: Bool = true
    @objc dynamic public var _licenseFeatures: Int = 0
    @objc dynamic public var _isActive: Bool = false
    @objc dynamic public var _voxLogin: String = ""
    @objc dynamic public var _voxPassword: String = ""
    @objc dynamic public var _allowMobileCalls: Bool = false
    @objc dynamic public var _isWorking: Bool = true
    @objc dynamic public var _isWorkingHidden: Bool = false

    public let _channels = List<JVChannel>()
    
    open override class func primaryKey() -> String? {
        return "_siteID"
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
