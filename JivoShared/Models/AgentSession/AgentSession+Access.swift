//
//  AgentSession+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
public enum AgentSessionWorkingState {
    case soon(WorktimeDayMeta?)
    case active
    case expiring(WorktimeDayConfig)
    case inactive(WorktimeDayMeta?)
    case hidden
}

extension AgentSession {
    public var sessionID: String {
        return _sessionID
    }
    
    public var email: String {
        return _email
    }
    
    public var isAdmin: Bool {
        return _isAdmin
    }
    
    public var isOperator: Bool {
        return _isOperator
    }
    
    public var siteID: Int {
        return _siteID
    }
    
    public var isActive: Bool {
        return _isActive
    }
    
    public var channels: [Channel] {
        return Array(_channels)
    }
    
    public var widgetChannels: [Channel] {
        return channels.filter { $0.jointType == nil }
    }
    
    public var allowMobileCalls: Bool {
        return _allowMobileCalls
    }
    
    public var voxCredentials: (login: String, password: String)? {
        guard let login = _voxLogin.valuable else { return nil }
        guard let password = _voxPassword.valuable else { return nil }
        return (login: login, password: password)
    }
    
    public var isWorking: Bool {
        return _isWorking
    }
    
    public var isWorkingHidden: Bool {
        return _isWorkingHidden
    }
    
    public var licenseFeatures: Int {
        return _licenseFeatures
    }
    
    public func globalFeatures() -> UserTechConfig {
        return UserTechConfig(
            guestInsightEnabled: _globalGuestsInsightEnabled,
            fileSizeLimit: _globalFileSizeLimit,
            disableArchiveForRegular: _globalDisableArchiveForRegular,
            iosTelephonyEnabled: _globalReceived ? _globalPlatformTelephonyEnabled : nil,
            limitedCRM: _globalLimitedCRM,
            assignedAgentEnabled: _globalAssignedAgentEnabled,
            messageEditingEnabled: _globalMessageEditingEnabled,
            groupsEnabled: _globalGroupsEnabled,
            mentionsEnabled: _globalMentionsEnabled,
            commentsEnabled: _globalCommentsEnabled,
            reactionsEnabled: _globalReactionsEnabled,
            businessChatEnabled: _globalBusinessChatEnabled,
            billingUpdateEnabled: _globalBillingUpdateEnabled,
            standaloneTasks: _globalStandaloneTasksEnabled,
            feedbackSdkEnabled: _globalFeedbackSdkEnabled,
            mediaServiceEnabled: _globalMediaServiceEnabled
        )
    }
    
    public func hasLicenseFeature(_ feature: UserLicensedFeature) -> Bool {
        let flag = 1 << feature.rawValue
        return (_licenseFeatures & flag) > 0
    }
    
    public func jointType(for channelID: Int) -> ChannelJoint? {
        let channel = _channels.first(where: { $0.ID == channelID })
        return channel?.jointType
    }
    
    public func testableChannels(lang: LocaleLang, codeHost: String?) -> [(channel: Channel, url: URL)] {
        return channels.compactMap { channel in
            guard
                channel.isTestable,
                let link = channel.name.valuable,
                let url = URL.widgetSumulator(
                    siteLink: link,
                    channelID: channel.publicID,
                    codeHost: codeHost?.split(separator: ".").first.flatMap(String.init),
                    lang: lang.rawValue)
            else { return nil }
            
            return (channel: channel, url: url)
        }
    }

    public static func obtainWorkingState(dayConfig: WorktimeDayConfig?,
                                   nextMetaPair: WorktimeDayMetaPair?,
                                   isWorking: Bool,
                                   isWorkingHidden: Bool) -> AgentSessionWorkingState {
        func _hash(_ hour: Int, _ minute: Int) -> Int {
            return hour * 60 + minute
        }
        
        if isWorkingHidden {
//            debug("{worktime} working-banner[hidden]")
            return .hidden
        }
        
        guard let dayConfig = dayConfig else {
//            debug("{worktime} working-banner[\(isWorking ? "active" : "hidden")]")
            return isWorking ? .active : .hidden
        }
        
        let hour = locale().calendar.component(.hour, from: Date())
        let minute = locale().calendar.component(.minute, from: Date())
        let nowHash = _hash(hour, minute)
        let startHash = _hash(dayConfig.startHour, dayConfig.startMinute)
        let expiringHash = _hash(dayConfig.endHour, dayConfig.endMinute) - 30
        let endHash = _hash(dayConfig.endHour, dayConfig.endMinute)
        
        if isWorking {
            if expiringHash <= nowHash, nowHash < endHash {
//                debug("{worktime} working-banner[expiring]")
                return .expiring(dayConfig)
            }
            else {
//                debug("{worktime} working-banner[active]")
                return .active
            }
        }
        else {
            if dayConfig.enabled, nowHash < startHash {
//                debug("{worktime} working-banner[soon]")
                return .soon(nextMetaPair?.today)
            }
            else {
//                debug("{worktime} working-banner[inactive]")
                return .inactive(nextMetaPair?.anotherDay)
            }
        }
    }
}
