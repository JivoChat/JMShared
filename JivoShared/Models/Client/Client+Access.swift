//
//  Client+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit
public enum ClientStatus {
    case none
    case alive
    case online
}
public enum ClientTypingStatus {
    case active(input: String?)
    case inactive
}
public enum ClientDetailsUpdateError: Error {
    case missing
    case invalid
    case tooLong
}
public struct ClientProfile {
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

extension Client: Displayable {
    public var senderType: SenderType {
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
    
    public var channel: Channel? {
        return _channel
    }

    public var isMe: Bool {
        return false
    }

    public func displayName(kind: DisplayNameKind) -> String {
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
    
    public func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        let url = _avatarLink.flatMap(URL.init)
        
        if let avatarID = String(_guestID.dropLast(3)).toHexInt() {
            let c = URL.generateAvatarURL(ID: avatarID)
            let image = JMRepicItemSource.avatar(URL: url, image: c.image, color: c.color, transparent: transparent)
            return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
        }
        else {
            let c = URL.generateAvatarURL(ID: UInt64(_ID))
            let image = JMRepicItemSource.avatar(URL: url, image: c.image, color: c.color, transparent: transparent)
            return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
        }
    }
    
    public var profile: ClientProfile {
        return ClientProfile(
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
    
    public func assignedAgent() -> Agent? {
        return _assignedAgent
    }
    
    public var navigatesNumber: Int {
        return max(1, _navigatesNumber)
    }
    
    public var session: ClientSession? {
        switch integration {
        case .none: return _activeSession
        case .some(let joint): return joint.isStandalone ? nil : _activeSession
        }
    }
    
    public var customData: [ClientCustomData] {
        return _customData.toArray()
    }
    
//    var proactiveRule: ClientProactiveRule? {
//        return _proactiveRule
//    }
    
    public var isOnline: Bool {
        if _isOnline {
            return true
        }
        else if _channel?.jointType != nil {
            return true
        }
        else if channel?.jointType == ChannelJoint.tel {
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
    
    public var integration: ChannelJoint? {
        if let joint = channel?.jointType {
            return joint
        }
        else if let integration = _integration?.valuable {
            return ChannelJoint(rawValue: integration)
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
        guard channel?.jointType == ChannelJoint.tel else { return false }
        return !profile.hasEmail
    }
    
    public var hasActiveCall: Bool {
        return _hasActiveCall
    }

    public var task: Task? {
        return _task
    }
    
    public var countryCode: String? {
        return _activeSession?.geo?.countryCode
    }
    
    public var isBlocked: Bool {
        return _isBlocked
    }
    
    public func export() -> ClientShortChange {
        return ClientShortChange(
            ID: ID,
            channelID: channel?.ID,
            task: nil)
    }
}
