//
//  JVClient+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

public enum JVClientStatus {
    case none
    case alive
    case online
}

public enum JVClientTypingStatus {
    case active(input: String?)
    case inactive
}

public enum JVClientDetailsUpdateError: Error {
    case missing
    case invalid
    case tooLong
}

public struct JVClientProfile {
    public let emailByClient: String?
    public let emailByAgent: String?
    public let phoneByClient: String?
    public let phoneByAgent: String?
    public let comment: String?
    public let countryName: String?
    public let cityName: String?
    
    public var hasEmail: Bool {
        if let _ = emailByClient { return true }
        if let _ = emailByAgent { return true }
        return false
    }
    
    public var primaryPhone: String? {
        return phoneByAgent ?? phoneByClient
    }
}

extension JVClient: JVDisplayable {
    public var senderType: JVSenderType {
        return .client
    }

    public var ID: Int {
        return _ID
    }
    
    public var publicID: String {
        return _publicID
    }
    
    public var chatID: Int? {
        if _chatID > .zero {
            return _chatID
        }
        else {
            return nil
        }
    }
    
    public var channelID: Int {
        return _channelID
    }
    
    public var channel: JVChannel? {
        return _channel
    }

    public var isMe: Bool {
        return false
    }

    public func displayName(kind: JVDisplayNameKind) -> String {
        switch kind {
        case .original where _displayName.isEmpty:
            return loc[format: "Client.Title", _ID]
        case .original:
            return _displayName
        case .short:
            return displayName(kind: .original)
        case .decorative:
            return displayName(kind: .original)
        case .relative:
            return String()
        }
    }
    
    public func metaImage(providers: JVMetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        let url = _avatarLink.flatMap(URL.init)
        
        if let avatarID = String(_guestID.dropLast(3)).jv_toHexInt() {
            let c = URL.jv_generateAvatarURL(ID: avatarID)
            let image = JMRepicItemSource.avatar(URL: url, image: c.image, color: c.color, transparent: transparent)
            return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
        }
        else {
            let c = URL.jv_generateAvatarURL(ID: UInt64(_ID))
            let image = JMRepicItemSource.avatar(URL: url, image: c.image, color: c.color, transparent: transparent)
            return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
        }
    }
    
    public var profile: JVClientProfile {
        return JVClientProfile(
            emailByClient: _emailByClient,
            emailByAgent: _emailByAgent,
            phoneByClient: _phoneByClient,
            phoneByAgent: _phoneByAgent,
            comment: _comment,
            countryName: _activeSession?.geo?.country,
            cityName: _activeSession?.geo?.city
        )
    }
    
    public var visitsNumber: Int {
        return max(1, _visitsNumber)
    }
    
    public func assignedAgent() -> JVAgent? {
        return _assignedAgent
    }
    
    public var navigatesNumber: Int {
        return max(1, _navigatesNumber)
    }
    
    public var session: JVClientSession? {
        switch integration {
        case .none: return _activeSession
        case .some(let joint): return joint.isStandalone ? nil : _activeSession
        }
    }
    
    public var customData: [JVClientCustomData] {
        return _customData.jv_toArray()
    }
    
//    var proactiveRule: JVClientProactiveRule? {
//        return _proactiveRule
//    }
    
    public var isOnline: Bool {
        if _isOnline {
            return true
        }
        else if _channel?.jointType != nil {
            return true
        }
        else if channel?.jointType == JVChannelJoint.tel {
            return true
        }
        else {
            return false
        }
    }
    
    public var displayAsOnline: Bool {
        if isOnline {
            return true
        }
            
        if channel?.jointType == nil, profile.hasEmail {
            return true
        }
        
        return false
    }
    
    public var hasIntegration: Bool {
        return (integration != nil)
    }
    
    public var integration: JVChannelJoint? {
        if let joint = channel?.jointType {
            return joint
        }
        else if let integration = _integration?.jv_valuable {
            return JVChannelJoint(rawValue: integration)
        }
        else {
            return nil
        }
    }
    
    public var hashedID: String {
        return "client:\(ID)"
    }

    public var isAvailable: Bool {
        return true
    }

    public var integrationURL: URL? {
        if let link = _integrationLink {
            return URL(string: link)
        }
        else {
            return nil
        }
    }
    
    public var requiresEmail: Bool {
        guard channel?.jointType == JVChannelJoint.tel else { return false }
        return !profile.hasEmail
    }
    
    public var hasActiveCall: Bool {
        return _hasActiveCall
    }

    public var task: JVTask? {
        return _task
    }
    
    public var countryCode: String? {
        return _activeSession?.geo?.countryCode
    }
    
    public var isBlocked: Bool {
        return _isBlocked
    }
    
    public func export() -> JVClientShortChange {
        return JVClientShortChange(
            ID: ID,
            channelID: channel?.ID,
            task: nil)
    }
}
