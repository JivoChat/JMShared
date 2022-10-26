//  
//  JVGuest+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit
public enum GuestStatus {
    case online
    case proactive(agent: JVAgent)
    case invited
    case chatting(withMe: Bool)
    case calling(withMe: Bool)
}

extension JVGuest: Displayable {
    public var senderType: SenderType {
        return .guest
    }

    public var ID: String {
        return _ID
    }

    public var channel: JVChannel? {
        abort()
    }
    
    public var channelID: String {
        return _channelID
    }
    
    public var agentID: Int {
        return _agentID
    }
    
    public var status: GuestStatus {
        switch _status {
        case "on_site":
            return .online
            
        case "proactive_show":
            return _proactiveAgent.flatMap(GuestStatus.proactive) ?? .online
            
        case "invite_sent":
            return .invited
            
        case "on_chat":
            let me = attendees.first(where: { $0.agent?.ID == _agentID })
            return .chatting(withMe: me != nil)
            
        case "on_call":
            let me = attendees.first(where: { $0.agent?.ID == _agentID })
            return .calling(withMe: me != nil)
            
        default:
            /*assertionFailure();*/
            return .online
        }
    }
    
    public var clientID: Int? {
        return (_clientID > 0 ?_clientID : nil)
    }
    
    public var isMe: Bool {
        return false
    }

    public var countryCode: String? {
        return _countryCode.valuable?.lowercased()
    }
    
    public var countryName: String? {
        return _countryName.valuable
    }
    
    public var regionName: String? {
        return _regionName.valuable
    }
    
    public var cityName: String? {
        return _cityName.valuable
    }
    
    public var organization: String? {
        return _organization.valuable
    }
    
    public var lastIP: String? {
        return _sourceIP.valuable
    }
    
    public func displayName(kind: DisplayNameKind) -> String {
        switch kind {
        case .original where _name.isEmpty:
            let defaultPrefix = loc["Visitor.Title"]
            let prefix = cityName ?? regionName ?? countryName ?? defaultPrefix
            return (_clientID > 0 ? "\(prefix) \(_clientID)" : prefix)
        case .original:
            return _name
        case .short:
            return displayName(kind: .original)
        case .decorative:
            return displayName(kind: .original)
        case .relative:
            return String()
        }
    }

    public func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        guard isValid else { return nil }
        
        if _clientID > 0, let client = providers?.clientProvider(_clientID) {
            let item = client.metaImage(providers: providers, transparent: false, scale: scale)
            return item
        }
        else if let avatarID = String(_ID.dropLast(3)).toHexInt() {
            let c = URL.generateAvatarURL(ID: avatarID)
            let image = JMRepicItemSource.avatar(URL: nil, image: c.image, color: c.color, transparent: transparent)
            return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
        }
        else {
            return nil
        }
    }
    
    public var phone: String? {
        return _phone.valuable
    }
    
    public var email: String? {
        return _email.valuable
    }
    
    public var integration: ChannelJoint? {
        return nil
    }
    
    public var hashedID: String {
        return "guest:\(ID)"
    }

    public var isAvailable: Bool {
        return true
    }

    public var pageURL: URL? {
        if let url = NSURL(string: _pageLink) {
            return url as URL
        }
        else {
            return nil
        }
    }
    
    public var pageTitle: String {
        return _pageTitle.valuable ?? _pageLink
    }
    
    public var startDate: Date? {
        return _startDate
    }
    
    public var UTM: JVClientSessionUTM? {
        return _utm
    }
    
    public var visitsNumber: Int {
        return _visitsNumber
    }
    
    public var navigatesNumber: Int {
        return _navigatesNumber
    }
    
    public var isVisible: Bool {
        return _visible
    }

    public var attendees: [JVChatAttendee] {
        return _attendees.toArray()
    }
    
    public var bots: [JVBot] {
        return _bots.toArray()
    }
    
    public func proactiveAgent() -> JVAgent? {
        if case .proactive = status {
            return _proactiveAgent
        }
        else {
            return nil
        }
    }
    
    public var lastUpdate: Date {
        return _lastUpdate ?? Date(timeIntervalSinceReferenceDate: 0)
    }
    
    public var hasBasicInfo: Bool {
        if _startDate == nil { return false }
        return true
    }
    
    public var disappearDate: Date? {
        return _disappearDate
    }
}

extension GuestStatus {
    public var iconName: String {
        switch self {
        case .online: return "vi_onsite"
        case .proactive: return "vi_proactive"
        case .invited: return "vi_invite"
        case .chatting: return "vi_onchat"
        case .calling: return "vi_oncall"
        }
    }
    
    public var title: String {
        switch self {
        case .online: return loc["Details.Visitor.Onsite"]
        case .proactive: return loc["Details.Visitor.Proactive"]
        case .invited: return loc["Details.Visitor.Invited"]
        case .chatting: return loc["Details.Visitor.Onchat"]
        case .calling: return loc["Details.Visitor.Oncall"]
        }
    }
}
