//
//  JVAgentSession+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import AVFoundation

public struct UserTechConfig: Codable {
    public var guestInsightEnabled: Bool = true
    public var fileSizeLimit: Int = 10
    public var disableArchiveForRegular: Bool = false
    public var iosTelephonyEnabled: Bool? = nil
    public var limitedCRM: Bool = true
    public var assignedAgentEnabled: Bool = true
    public var messageEditingEnabled: Bool = true
    public var groupsEnabled: Bool = true
    public var mentionsEnabled: Bool = true
    public var commentsEnabled: Bool = true
    public var reactionsEnabled: Bool = true
    public var businessChatEnabled: Bool = true
    public var billingUpdateEnabled: Bool = true
    public var standaloneTasks: Bool = true
    public var feedbackSdkEnabled: Bool = true
    public var mediaServiceEnabled: Bool = true

    public init() {}
    
    public init(
        guestInsightEnabled: Bool,
        fileSizeLimit: Int,
        disableArchiveForRegular: Bool,
        iosTelephonyEnabled: Bool?,
        limitedCRM: Bool,
        assignedAgentEnabled: Bool,
        messageEditingEnabled: Bool,
        groupsEnabled: Bool,
        mentionsEnabled: Bool,
        commentsEnabled: Bool,
        reactionsEnabled: Bool,
        businessChatEnabled: Bool,
        billingUpdateEnabled: Bool,
        standaloneTasks: Bool,
        feedbackSdkEnabled: Bool,
        mediaServiceEnabled: Bool
    ) {
        self.guestInsightEnabled = guestInsightEnabled
        self.fileSizeLimit = fileSizeLimit
        self.disableArchiveForRegular = disableArchiveForRegular
        self.iosTelephonyEnabled = iosTelephonyEnabled
        self.limitedCRM = limitedCRM
        self.assignedAgentEnabled = assignedAgentEnabled
        self.messageEditingEnabled = messageEditingEnabled
        self.groupsEnabled = groupsEnabled
        self.mentionsEnabled = mentionsEnabled
        self.commentsEnabled = commentsEnabled
        self.reactionsEnabled = reactionsEnabled
        self.businessChatEnabled = businessChatEnabled
        self.billingUpdateEnabled = billingUpdateEnabled
        self.standaloneTasks = standaloneTasks
        self.feedbackSdkEnabled = feedbackSdkEnabled
        self.mediaServiceEnabled = mediaServiceEnabled
    }
    
    public var canReceiveCalls: Bool? {
        guard let enabled = iosTelephonyEnabled else { return nil }
        guard AVAudioSession.sharedInstance().recordPermission != .denied else { return false }
        return enabled
    }
}
public enum UserLicensedFeature: Int {
    case blacklist
    case geoip
    case phrases
    case transfer
    case invite
    case away
    case typing
    case info
    case files
    case guests
    
    public func resolveBit(within raw: Int) -> Bool {
        return (raw & (1 << rawValue)) > 0
    }
}

extension JVAgentSession {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? AgentSessionGeneralChange {
            if _siteID == 0 { _siteID = c.siteID }
            _sessionID = c.sessionID
            _email = c.email
            _isAdmin = c.isAdmin
            _isOperator = c.isOperator
            _licenseFeatures = c.licenseFeatures
            _isActive = true
            _voxLogin = c.voxLogin
            _voxPassword = c.voxPassword
            _allowMobileCalls = c.mobileCalls
            _isWorking = c.workingState
            
//            debug("{worktime} session-change-apply is-working[\(_isWorking)]")
        }
        else if let c = change as? AgentSessionContextChange {
            
//            _channels.set(context.upsert(of: JVChannel.self, with: c.channels))

            if let features = c.techConfig {
                _globalReceived = true
                _globalGuestsInsightEnabled = features.guestInsightEnabled
                _globalFileSizeLimit = features.fileSizeLimit
                _globalDisableArchiveForRegular = features.disableArchiveForRegular
                _globalPlatformTelephonyEnabled = features.iosTelephonyEnabled ?? true
                _globalLimitedCRM = features.limitedCRM
                _globalAssignedAgentEnabled = features.assignedAgentEnabled
                _globalMessageEditingEnabled = features.messageEditingEnabled
                _globalGroupsEnabled = features.groupsEnabled
                _globalMentionsEnabled = features.mentionsEnabled
                _globalCommentsEnabled = features.commentsEnabled
                _globalReactionsEnabled = features.reactionsEnabled
                _globalBusinessChatEnabled = features.businessChatEnabled
                _globalBillingUpdateEnabled = features.billingUpdateEnabled
                _globalStandaloneTasksEnabled = features.standaloneTasks
                _globalFeedbackSdkEnabled = features.feedbackSdkEnabled
                _globalMediaServiceEnabled = features.mediaServiceEnabled
            }
        }
        else if let c = change as? AgentSessionMobileCallsChange {
            _allowMobileCalls = c.enabled
        }
        else if let c = change as? AgentSessionWorktimeChange {
            _isWorking = c.isWorking ?? _isWorking
            _isWorkingHidden = c.isWorkingHidden
        }
        else if let c = change as? AgentSessionChannelsChange {
            _channels.set(context.upsert(of: JVChannel.self, with: c.channels))
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _channels.toArray(), recursive: true)
    }
}

public final class AgentSessionGeneralChange: BaseModelChange, Codable {
    public var sessionID: String
    public var email: String
    public var siteID: Int
    public var isAdmin: Bool
    public var isOperator: Bool
    public var licenseFeatures: Int
    public var voxLogin: String
    public var voxPassword: String
    public var mobileCalls: Bool
    public var workingState: Bool
    
    public override var primaryValue: Int {
        return siteID
    }
    
    public override var isValid: Bool {
        guard let _ = sessionID.valuable else { return false }
        return true
    }
    
    required public init( json: JsonElement) {
        sessionID = json["agent_info"]["agent_session_id"].string ?? json["jv_sess_id"].stringValue
        email = json["agent_info"]["email"].stringValue
        isAdmin = json["agent_info"]["is_admin"].boolValue
        isOperator = json["agent_info"]["is_operator"].bool ?? true
        siteID = json["agent_info"]["site_id"].intValue
        licenseFeatures = parseFeatures(source: json["features"])
        voxLogin = json["agent_info"]["vox_name"].stringValue
        voxPassword = json["agent_info"]["vox_password"].stringValue
        mobileCalls = json["agent_info"]["calls_mobile"].boolValue
        workingState = ((json["agent_info"]["work_state"].int ?? 1) > 0)
        super.init(json: json)
    }
}

public final class AgentSessionContextChange: BaseModelChange {
    public let scanned: Bool
    public let widgetPublicID: String?
    public let agentsJSON: JsonElement?
    public let agents: [AgentGeneralChange]?
    public let clients: [ClientGeneralChange]?
    public let techConfig: UserTechConfig?
    public let currency: String?
    public let pricelistID: Int?
    public let licenseLimit: Int?

    public override var isValid: Bool {
        return scanned
    }
    
    required public init( json: JsonElement) {
        if let context = json.has(key: "rmo_context") {
            scanned = true
            
            widgetPublicID = context["sites"].arrayValue.first?["public_id"].string
            agentsJSON = context.has(key: "agents")
            
            agents = agentsJSON?.parseList()
            clients = context["clients"].parseList()
            
            if let misc = context.has(key: "misc") {
                techConfig = UserTechConfig(
                    guestInsightEnabled: ((misc["disable_visitors_insight"].int ?? 0) == 0),
                    fileSizeLimit: misc["max_file_size"].intValue,
                    disableArchiveForRegular: ((misc["disable_archive_non_admins"].int ?? 0) > 0),
                    iosTelephonyEnabled: ((misc["enable_ios_telephony"].int ?? 1) > 0),
                    limitedCRM: ((misc["enable_crm"].int ?? 1) > 0),
                    assignedAgentEnabled: ((misc["enable_assigned_agent"].int ?? 1) > 0),
                    messageEditingEnabled: ((misc["enable_message_edit"].int ?? 1) > 0),
                    groupsEnabled: ((misc["enable_team_chats"].int ?? 1) > 0),
                    mentionsEnabled: ((misc["enable_mentions"].int ?? 1) > 0),
                    commentsEnabled: ((misc["enable_comments"].int ?? 1) > 0),
                    reactionsEnabled: ((misc["enable_reactions"].int ?? 1) > 0),
                    businessChatEnabled: ((misc["enable_imessage"].int ?? 1) > 0),
                    billingUpdateEnabled: ((misc["enable_new_billing"].int ?? 1) > 0 && ((misc["is_operator_model_enabled"].int ?? 1) > 0)),
                    standaloneTasks: ((misc["enable_reminder_without_open_chat"].int ?? 1) > 0),
                    feedbackSdkEnabled: ((misc["enable_feedback_sdk"].int ?? 1) > 0),
                    mediaServiceEnabled: ((misc["enable_media_service_uploading"].int ?? 0) > 0)
                )
                
                currency = misc["currency"].string
                pricelistID = misc["pricelist_id"].int
                licenseLimit = misc["license_limit"].int
            }
            else {
                techConfig = nil
                currency = nil
                pricelistID = nil
                licenseLimit = nil
            }
        }
        else {
            scanned = false
            widgetPublicID = nil
            agentsJSON = JsonElement()
            agents = []
            clients = []
            techConfig = nil
            currency = nil
            pricelistID = nil
            licenseLimit = nil
        }
        
        super.init(json: json)
    }
}

public final class AgentSessionBoxesChange: BaseModelChange {
    public let source: JsonElement
    public let chats: [ChatGeneralChange]
    
    required public init( json: JsonElement) {
        source = json
        chats = json["chats"].parseList() ?? []
        super.init(json: json)
    }
        public init(source: JsonElement, chats: [ChatGeneralChange]) {
        self.source = source
        self.chats = chats
        super.init()
    }

    public var clientChats: [ChatGeneralChange] {
        return chats.filter { $0.client != nil }
    }

    public var teamChats: [ChatGeneralChange] {
        return chats.filter { not($0.isGroup == true) && $0.client == nil }
    }
    
    public var groupChats: [ChatGeneralChange] {
        return chats.filter { ($0.isGroup == true) }
    }
    
    public var chatIDs: [Int] {
        return chats.map { $0.ID }
    }
    
    public func cachable() -> AgentSessionBoxesChange {
        return AgentSessionBoxesChange(
            source: source,
            chats: chats.map { $0.cachable() }
        )
    }
}

public final class AgentSessionActivityChange: BaseModelChange {
    public let isActive: Bool
        public init(isActive: Bool) {
        self.isActive = isActive
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class AgentSessionMobileCallsChange: BaseModelChange {
    public let enabled: Bool
        public init(enabled: Bool) {
        self.enabled = enabled
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class AgentSessionWorktimeChange: BaseModelChange {
    public let agentID: Int?
    public let isWorking: Bool?
    public let isWorkingHidden: Bool
        public init(isWorking: Bool?, isWorkingHidden: Bool) {
        self.agentID = nil
        self.isWorking = isWorking
        self.isWorkingHidden = isWorkingHidden
        super.init()
    }
    
    required public init( json: JsonElement) {
        agentID = json["agent_id"].int
        isWorking = json["work_state"].int.flatMap { $0 > 0 }
        isWorkingHidden = false
        super.init(json: json)
    }
}

public final class AgentSessionChannelsChange: BaseModelChange {
    public let channels: [ChannelGeneralChange]
    public init(channels: [ChannelGeneralChange]) {
        self.channels = channels
        super.init()
    }
    
    required public init( json: JsonElement) {
        channels = []
        super.init(json: json)
    }
}
public func parseFeatures(source: JsonElement) -> Int {
    func _bit(key: String, flag: UserLicensedFeature) -> Int {
        let value = source[key].boolValue ? 1 : 0
        return (value << flag.rawValue)
    }
    
    let flags: [Int] = [
        _bit(key: "blacklist", flag: .blacklist),
        _bit(key: "geoip", flag: .geoip),
        _bit(key: "canned", flag: .phrases),
        _bit(key: "redirect", flag: .transfer),
        _bit(key: "multiagents", flag: .invite),
        _bit(key: "away", flag: .away),
        _bit(key: "typing_insight", flag: .typing),
        _bit(key: "page_info", flag: .info),
        _bit(key: "file_transfer", flag: .files),
        _bit(key: "visitors_insight", flag: .guests)
    ]
    
    return flags.reduce(0, +)
}
