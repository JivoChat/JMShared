//
//  Agent+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

public enum AgentState: Int {
    case none
    case active
    case away
}
public enum AgentCallingDestination: Int {
    case disabled = 0
    case sip = 1
    case phone = 2
    case app = 3

    public var isExternal: Bool {
        switch self {
        case .disabled: return false
        case .sip: return true
        case .phone: return true
        case .app: return false
        }
    }
}
public enum AgentCallingOptions: Int {
    case availableForCalls
    case availableForMobileCalls
    case onCall
    case supportsAway
    case supportsOffline
}
public enum AgentOrderingGroup: Int {
    case offline
    case awayZZ
    case onlineZZ
    case away
    case online
}

extension Agent: Displayable {
    public var senderType: SenderType {
        return .agent
    }

    public var ID: Int {
        return _ID
    }
    
    public var publicID: String {
        return _publicID
    }
    
    public var email: String {
        return _email
    }
    
    public var nickname: String {
        return email.split(separator: "@").first.flatMap(String.init) ?? String()
    }
    
    public var phone: String? {
        return _phone.valuable
    }
    
    public var isMe: Bool {
        return (_session != nil)
    }
    
    public var notMe: Bool {
        return not(isMe)
    }
    
    public var state: AgentState {
        get { return AgentState(rawValue: _stateID) ?? .active }
        set { _stateID = newValue.rawValue }
    }
    
    public var isWorktimeEnabled: Bool {
        return _session?.isWorking ?? _isWorking
    }
    
    public var stateColor: UIColor? {
        switch state {
        case .none: return nil
        case .active: return DesignBook.shared.color(usage: .onlineTint)
        case .away: return DesignBook.shared.color(usage: .awayTint)
        }
    }
    
    public var channel: Channel? {
        return nil
    }
    
    public var statusImage: UIImage? {
        switch state {
        case .active where isWorktimeEnabled: return UIImage(named: "status_def_online")
        case .active: return UIImage(named: "status_def_online_sleep")
        case .away where isWorktimeEnabled: return UIImage(named: "status_def_away")
        case .away: return UIImage(named: "status_def_away_sleep")
        case .none where isWorktimeEnabled: return UIImage(named: "status_def_offline")
        case .none: return UIImage(named: "status_def_offline_sleep")
        }
    }
    
    public func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        let url = _avatarLink.flatMap(URL.init)
        let icon = UIImage(named: "avatar_agent")
        let image = JMRepicItemSource.avatar(URL: url, image: icon, color: nil, transparent: transparent)
        return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
    }
    
    public func displayName(kind: DisplayNameKind) -> String {
        switch kind {
        case .original:
            return _displayName
        case .short:
            let originalName = displayName(kind: .original)
            let clearName = originalName.trimmingCharacters(in: .whitespaces)
            let slices = (clearName as NSString).components(separatedBy: .whitespaces)
            return (slices.count > 1 ? "\(slices[0]) \(slices[1].prefix(1))." : clearName)
        case .decorative where _isOperator:
            return displayName(kind: .original) + "✨"
        case .decorative:
            return displayName(kind: .original)
        case .relative where isMe:
            return loc["Message.Sender.You"]
        case .relative:
            return displayName(kind: .original)
        }
    }
    
    public var title: String {
        return _title
    }
    
    public var isAdmin: Bool {
        return _isAdmin
    }

    public var isOperator: Bool {
        return _isOperator
    }

    public var callingDestination: AgentCallingDestination {
        return AgentCallingDestination(rawValue: _callingDestination) ?? .disabled
    }

    public var draft: String? {
        return _draft?.valuable
    }
    
    public func availableForChatInvite(operatorsOnly: Bool) -> Bool {
        if operatorsOnly, not(isOperator) {
            return false
        }
        
        switch state {
        case .none: return false
        case .active: return true
        case .away: return true
        }
    }

    public func availableForChatTransfer(operatorsOnly: Bool) -> Bool {
        if operatorsOnly, not(isOperator) {
            return false
        }
        
        switch state {
        case .none: return false
        case .active: return true
        case .away: return true
        }
    }

    public var availableForCallTransfer: Bool {
        if isMe {
            return false
        }
        
        if callingDestination == .disabled {
            return false
        }

        switch state {
        case .none where callingDestination.isExternal: return _callingOptions.hasBit(AgentCallingOptions.supportsOffline.rawValue)
        case .none: return false
        case .active: return true
        case .away: return _callingOptions.hasBit(AgentCallingOptions.supportsAway.rawValue)
        }
    }

    public var session: AgentSession? {
        return _session
    }
    
    public var lastMessage: Message? {
        return _lastMessage
    }
    
    public var chat: Chat? {
        return _chat
    }
    
    public var integration: ChannelJoint? {
        return nil
    }
    
    public var hashedID: String {
        return "agent:\(ID)"
    }

    public var isAvailable: Bool {
        switch state {
        case .none: return false
        case .active: return true
        case .away: return true
        }
    }

    public var onCall: Bool {
        return _callingOptions.hasBit(1 << AgentCallingOptions.onCall.rawValue)
    }
    
    public var worktime: Worktime? {
        return _worktime
    }
    
    public var hasSession: Bool {
        return _hasSession
    }
    
    public var lastMessageDate: Date? {
        return _lastMessageDate
    }
    
    public var orderingGroup: Int {
        return _orderingGroup
    }
    
    public var orderingName: String {
        return _orderingName ?? String()
    }
    
    public var isExisting: Bool {
        return not(_email.isEmpty)
    }
}
