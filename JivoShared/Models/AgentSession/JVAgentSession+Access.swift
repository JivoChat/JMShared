//
//  _JVAgentSession+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public enum JVAgentSessionWorkingState {
    case soon(JVWorktimeDayMeta?)
    case active
    case expiring(JVWorktimeDayConfig)
    case inactive(JVWorktimeDayMeta?)
    case hidden
}

extension _JVAgentSession {
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
    
    public var channels: [_JVChannel] {
        return Array(_channels)
    }
    
    public var widgetChannels: [_JVChannel] {
        return channels.filter { $0.jointType == nil }
    }
    
    public var priceListId: Int? {
        if _globalPricelistId > 0 {
            return _globalPricelistId
        }
        else {
            return nil
        }
    }
    
    public var allowMobileCalls: Bool {
        return _allowMobileCalls
    }
    
    public var voxCredentials: (login: String, password: String)? {
        guard let login = _voxLogin.jv_valuable else { return nil }
        guard let password = _voxPassword.jv_valuable else { return nil }
        return (login: login, password: password)
    }
    
    public var isWorking: Bool {
        return _isWorking
    }
    
    public var isWorkingHidden: Bool {
        return _isWorkingHidden
    }
    
    public func globalFeatures() -> JVAgentTechConfig {
        return JVAgentTechConfig(
            priceListId: (_globalPricelistId > 0 ? _globalPricelistId : nil),
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
            mediaServiceEnabled: _globalMediaServiceEnabled,
            voiceMessagesEnabled: _globalVoiceMessagesEnabled
        )
    }
    
    public func jointType(for channelID: Int) -> JVChannelJoint? {
        let channel = _channels.first(where: { $0.ID == channelID })
        return channel?.jointType
    }
    
    public func testableChannels(domain: String, lang: JVLocaleLang, codeHost: String?) -> [(channel: _JVChannel, url: URL)] {
        return channels.compactMap { channel in
            guard
                channel.isTestable,
                let link = channel.name.jv_valuable,
                let url = URL.jv_widgetSumulator(
                    domain: domain,
                    siteLink: link,
                    channelID: channel.publicID,
                    codeHost: codeHost,
                    lang: lang.rawValue)
            else { return nil }
            
            return (channel: channel, url: url)
        }
    }

    public static func obtainWorkingState(dayConfig: JVWorktimeDayConfig?,
                                   nextMetaPair: JVWorktimeDayMetaPair?,
                                   isWorking: Bool,
                                   isWorkingHidden: Bool) -> JVAgentSessionWorkingState {
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
        
        let hour = JVActiveLocale().calendar.component(.hour, from: Date())
        let minute = JVActiveLocale().calendar.component(.minute, from: Date())
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
