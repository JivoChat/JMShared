//
//  JVChat+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit
public enum ChatReactionPerforming {
    case accept
    case decline
    case spam
    case close
}
public enum ChatInvitationState {
    case none
    case activeBySystem
    case activeByAgent(JVAgent)
    case cancelBySystem
    case cancelByAgent(JVAgent)
    
    public var isNone: Bool {
        if case .none = self {
            return true
        }
        else {
            return false
        }
    }
}
public enum ChatTransferState {
    case none
    case requested(agent: JVAgent, assisting: Bool, comment: String?)
    case completed(agent: JVAgent, assisting: Bool, date: Date, comment: String?)
    case rejected(agent: JVAgent, assisting: Bool, reason: String)
}
public enum ChatAttendeeAssignment {
    case assignedWithMe
    case assignedToAnother
    case notPresented
}

extension JVChat: Presentable {
    public var ID: Int {
        return _ID
    }
    
    public var isGroup: Bool {
        return _isGroup
    }
    
    public var isMain: Bool {
        return _isMain
    }
    
    public var client: JVClient? {
        return validate(_client)
    }
    
    public var hasClient: Bool {
        return (client != nil)
    }
    
    public var title: String {
        return _title ?? _client?.displayName(kind: .decorative) ?? String()
    }
    
    public var about: String? {
        return _about?.valuable
    }
    
    public var attendees: [JVChatAttendee] {
        if _attendees.isInvalidated {
            return []
        }
        else {
            return _attendees.toArray()
        }
    }
    
    public var attendee: JVChatAttendee? {
        return _attendee
    }
    
    public var allAttendees: [JVChatAttendee] {
        return attendees.filter {
            if case .attendee = $0.relation {
                return true
            }
            else {
                return false
            }
        }
    }
    
    public var invitationState: ChatInvitationState {
        if _requestCancelledBySystem {
            return .cancelBySystem
        }
        else if let agent = _requestCancelledByAgent {
            return .cancelByAgent(agent)
        }
        else if let attendee = attendee {
            if case .invitedBySystem = attendee.relation {
                return _transferCancelled ? .none : .activeBySystem
            }
            else if case .invitedByAgent(let agent, _, _) = attendee.relation {
                return _transferCancelled ? .none : .activeByAgent(agent)
            }
            else {
                return .none
            }
        }
        else {
            return .none
        }
    }
    
    public var isCancelled: Bool {
        switch invitationState {
        case .none: return false
        case .activeBySystem: return false
        case .activeByAgent: return false
        case .cancelBySystem: return true
        case .cancelByAgent: return true
        }
    }
    
    public var agents: [JVAgent] {
        return attendees.compactMap { $0.agent }
    }
    
    public var lastMessage: JVMessage? {
        return _lastMessage
    }
    
    public var previewMessage: JVMessage? {
        return _previewMessage ?? _lastMessage
    }

    public var lastMessageValid: Bool {
        return _lastMessageValid
    }
    
    public var loadedPartialHistory: Bool {
        return _loadedPartialHistory
    }
    
    public var loadedEntireHistory: Bool {
        return _loadedEntireHistory
    }
    
    public var realUnreadNumber: Int {
        if let message = lastMessage, message.sentByMe {
            return 0
        }
        else if _unreadNumber > -1 {
            return _unreadNumber
        }
        else if let identifier = attendee?.receivedMessageID, let lastID = lastMessage?.ID {
            return (identifier == lastID ? 0 : 1)
        }
        else {
            return 0
        }
    }
    
    public var notifyingUnreadNumber: Int {
        if notifying == .nothing {
            return 0
        }
        else {
            return realUnreadNumber
        }
    }
    
    public enum UnreadMarkPosition { case null, position(Int), identifier(Int) }
    public var unreadMarkPosition: UnreadMarkPosition {
        if let message = lastMessage, message.sentByMe {
            return .null
        }
        else if let identifier = attendee?.receivedMessageID, let lastID = lastMessage?.ID {
            return (identifier == lastID ? .null : .identifier(identifier))
        }
        else {
            return (realUnreadNumber > 0 ? .position(realUnreadNumber) : .null)
        }
    }
    
    public var transferState: ChatTransferState {
        if let agent = _transferTo {
            if let date = _transferDate {
                return .completed(
                    agent: agent,
                    assisting: _transferAssisting,
                    date: date,
                    comment: _transferComment
                )
            }
            else if let reason = _transferFailReason {
                return .rejected(
                    agent: agent,
                    assisting: _transferAssisting,
                    reason: reason
                )
            }
            else {
                return .requested(
                    agent: agent,
                    assisting: _transferAssisting,
                    comment: _transferComment
                )
            }
        }
        else {
            return .none
        }
    }
    
    public var terminationDate: Date? {
        return _terminationDate
    }

    public var hasActiveCall: Bool {
        return _hasActiveCall
    }
    
    public var lastActivityTimestamp: TimeInterval {
        return _lastActivityTimestamp
    }
    
    public var department: String? {
        return _department?.valuable
    }
    
    public var draft: String? {
        return _draft?.valuable
    }
    
    public var notifying: ChatAttendeeNotifying? {
        if isGroup {
            return attendee?.notifying
        }
        else {
            return .everything
        }
    }
    
    public var senderType: SenderType {
        return .teamchat
    }
    
    public func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        guard isGroup else { return nil }
        guard let code = _icon?.valuable else { return nil }
        
        return JMRepicItem(
            backgroundColor: DesignBook.shared.color(usage: .contentBackground),
            source: JMRepicItemSource.caption(code, DesignBook.shared.baseEmojiFont(scale: scale)),
            scale: scale ?? 0.55,
            clipping: .external)
    }
    
    public func transferredFrom() -> (agent: JVAgent, comment: String?)? {
        guard let attendee = attendee else { return nil }
        guard case let .attendee(agent, toAssist, comment) = attendee.relation else { return nil }
        guard let a = agent, !toAssist else { return nil }
        return (a, comment)
    }

    public func transferredTo() -> (agent: JVAgent, comment: String?)? {
        guard let agent = _transferTo, !agent.isMe else { return nil }
        guard !_transferAssisting else { return nil }
        guard let _ = _transferDate else { return nil }
        return (agent, _transferComment)
    }

    public func assistingFrom() -> (agent: JVAgent, comment: String?)? {
        guard let attendee = attendee else { return nil }
        guard case let .attendee(agent, toAssist, comment) = attendee.relation else { return nil }
        guard let a = agent, toAssist else { return nil }
        return (a, comment)
    }

    public func assistingTo() -> (agent: JVAgent, comment: String?)? {
        guard let agent = _transferTo, !agent.isMe else { return nil }
        guard _transferAssisting else { return nil }
        guard let _ = _transferDate else { return nil }
        return (agent, _transferComment)
    }

    public func selfJoined() -> Bool {
        guard let attendee = attendee else { return false }
        guard case let .attendee(agent, _, _) = attendee.relation else { return false }
        guard agent == nil else { return false }
        return true
    }
    
    public func isTransferredAway() -> Bool {
        if let _ = _transferDate, !_transferAssisting {
            return true
        }
        else {
            return false
        }
    }
    
    public func activeAttendees(withMe: Bool) -> [JVChatAttendee] {
        let selfAttendee: [JVChatAttendee]
        if withMe, let attendee = attendee, case .attendee = attendee.relation {
            selfAttendee = [attendee]
        }
        else {
            selfAttendee = []
        }
        
        let otherAttendees = attendees.filter {
            guard case .attendee = $0.relation else { return false }
            guard !($0.agent?.isMe == true) else { return false }
            return true
        }
        
        return selfAttendee + otherAttendees
    }
    
    public func teamAttendees(withMe: Bool) -> [JVChatAttendee] {
        let selfAttendee: [JVChatAttendee]
        if withMe, let attendee = attendee, case .team = attendee.relation {
            selfAttendee = [attendee]
        }
        else {
            selfAttendee = []
        }
        
        let otherAttendees = attendees.filter {
            guard case .team = $0.relation else { return false }
            guard !($0.agent?.isMe == true) else { return false }
            return true
        }
        
        return selfAttendee + otherAttendees
    }
    
    public func attendeeAssignment(for ID: Int) -> ChatAttendeeAssignment {
        if attendee == nil, attendees.isEmpty {
            return .notPresented
        }
        else if attendee?.agent?.ID == ID {
            return .assignedWithMe
        }
        else if attendees.compactMap({ $0.agent?.ID }).contains(ID) {
            return .assignedWithMe
        }
        else {
            return .assignedToAnother
        }
    }
    
    public var isArchived: Bool {
        return _isArchived
    }

    public var recipient: Sender? {
        if let client = client {
            return Sender(type: .client, ID: client.ID)
        }
        else if let agent = teamAttendees(withMe: false).first?.agent {
            return Sender(type: .agent, ID: agent.ID)
        }
        else if let agent = attendee?.agent {
            return Sender(type: .agent, ID: agent.ID)
        }
        else {
            return nil
        }
    }
    
    public var notifyingCaptionStatus: String {
        guard let status = notifying else {
            return loc["Details.Group.EnableAlerts.On"]
        }
        
        switch status {
        case .nothing: return loc["Details.Group.EnableAlerts.Off"]
        case .everything: return loc["Details.Group.EnableAlerts.On"]
        case .mentions: return loc["Details.Group.EnableAlerts.Mentions"]
        }
    }
    
    public var notifyingCaptionAction: String {
        guard let status = notifying else {
            return loc["Teambox.Options.Everything"]
        }
        
        switch status {
        case .everything: return loc["Teambox.Options.Everything"]
        case .nothing: return loc["Teambox.Options.Nothing"]
        case .mentions: return loc["Teambox.Options.Mentions"]
        }
    }
    
    public var owningAgent: JVAgent? {
        return _owningAgent
    }
    
    public func hasAttendee(agent: JVAgent) -> Bool {
        for attendee in attendees {
            guard agent.ID == attendee.agent?.ID else { continue }
            return true
        }
        
        return false
    }
    
    public func hasManagingAccess(agent: JVAgent) -> Bool {
        guard isGroup && not(isMain) else { return false }
        if _owningAgent?.ID == agent.ID { return true }
        if agent.isAdmin { return true }
        return false
    }
    
    public func export() -> ChatShortChange {
        return ChatShortChange(
            ID: _ID,
            client: _client?.export(),
            attendee: _attendee?.export(),
            teammateID: _attendees.first?.agent?.ID,
            isGroup: _isGroup,
            title: _title,
            about: _about,
            icon: _icon,
            isArchived: _isArchived)
    }
    
    public func isAvailable(accepting: Bool, joining: Bool) -> Bool {
        switch attendee?.relation {
        case .invitedBySystem: return accepting
        case .invitedByAgent: return joining
        case .attendee: return true
        case .team: return true
        case nil: return true
        }
    }
}
