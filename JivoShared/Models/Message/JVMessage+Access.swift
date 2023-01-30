//
//  JVMessage+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright Â© 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

public enum JVMessageContent {
    case proactive(message: String)
    case offline(message: String)
    case text(message: String)
    case comment(message: String)
    case bot(message: String, buttons: [String], markdown: Bool)
    case order(email: String?, phone: String?, subject: String, details: String, button: String)
    case email(from: String, to: String, subject: String, message: String)
    case photo(mime: String, name: String, link: String, dataSize: Int, width: Int, height: Int)
    case file(mime: String, name: String, link: String, size: Int)
    case transfer(from: JVAgent, to: JVAgent)
    case transferDepartment(from: JVAgent, department: JVDepartment, to: JVAgent)
    case join(assistant: JVAgent, by: JVAgent?)
    case left(agent: JVAgent, kicker: JVAgent?)
    case call(call: JVMessageBodyCall)
    case task(task: JVMessageBodyTask)
    case conference(conference: JVMessageBodyConference)
    case story(story: JVMessageBodyStory)
    case line
    case contactForm(status: JVMessageBodyContactFormStatus)

    public var isEditable: Bool {
        switch self {
        case .proactive: return false
        case .offline: return false
        case .text: return true
        case .comment: return true
        case .email: return false
        case .photo: return false
        case .file: return false
        case .transfer: return false
        case .transferDepartment: return false
        case .join: return false
        case .left: return false
        case .call: return false
        case .task: return false
        case .line: return false
        case .conference: return false
        case .story: return false
        case .bot: return false
        case .order: return false
        case .contactForm: return false
        }
    }
    
    public var isDeletable: Bool {
        switch self {
        case .proactive: return false
        case .offline: return true
        case .text: return true
        case .comment: return true
        case .email: return false
        case .photo: return true
        case .file: return true
        case .transfer: return false
        case .transferDepartment: return false
        case .join: return false
        case .left: return false
        case .call: return false
        case .task: return false
        case .line: return false
        case .conference: return false
        case .story: return false
        case .bot: return false
        case .order: return false
        case .contactForm: return false
        }
    }
}

public struct JVMessageContentHash {
    public let ID: Int
    public let value: Int
    
    public func hasChanged(relatedTo anotherHash: JVMessageContentHash?) -> Bool {
        guard let anotherHash = anotherHash else { return false }
        guard ID == anotherHash.ID else { return false }
        return (value != anotherHash.value)
    }
}

public struct JVMessageUpdateMeta {
    let agent: JVAgent
    let date: Date
}

public struct JVMessageReactor: Codable {
    public let subjectKind: String
    public let subjectID: Int
    
    public init(subjectKind: String, subjectID: Int) {
        self.subjectKind = subjectKind
        self.subjectID = subjectID
    }
}

public struct JVMessageReaction: Codable {
    public let emoji: String
    public var reactors: [JVMessageReactor]
    
    public init(emoji: String, reactors: [JVMessageReactor]) {
        self.emoji = emoji
        self.reactors = reactors
    }
}

public enum JVMessageDirection {
    case system
    case incoming
    case outgoing
}

public enum JVMessageStatus: String {
    case sent = "sent"
    case delivered = "delivered"
    case seen = "seen"
    case historic = "received"
    var serverCode: String { rawValue }
}

public enum JVMessageDelivery {
    case none
    case sending
    case failed
    case status(JVMessageStatus)
}

public enum JVMessageType: String {
    case message = "message"
    case contactForm = "contact_form"
}

public extension JVMessage {
    struct Identifiers {
        static let offlineMessage = -1
    }
}

public extension JVMessage {
    var UUID: String {
        return _UUID
    }
    
    var ID: Int {
        return _ID
    }
    
    var localID: String {
        return _localID
    }
    
    var date: Date {
        return _date!
    }
    
    var clientID: Int {
        return _clientID
    }
    
    var client: JVClient? {
        return jv_validate(_client)
    }
    
    var chatID: Int {
        return _chatID
    }
    
    var direction: JVMessageDirection {
        if ["system", "transfer", "join", "left", "line", "reminder"].contains(type) {
            return .system
        }
        else if call?.type == JVMessageBodyCallType.incoming {
            return .incoming
        }
        else if _isIncoming {
            return .incoming
        }
        else {
            return .outgoing
        }
    }
    
    var type: String {
        guard !(isDeleted) else {
            return "message"
        }
        
        return _type
    }
    
    var isSystemLike: Bool {
        switch type {
        case "proactive": return false
        case "email": return false
        case "message": return false
        case "transfer": return true
        case "join": return true
        case "left": return true
        case "system": return true
        case "call": return true
        case "line": return true
        case "reminder": return true
        case "comment": return false
        case "keyboard": return false
        case "order": return false
        default: return true
        }
    }
    
    var content: JVMessageContent {
        switch type {
        case "proactive":
            return .proactive(
                message: _text
            )
            
        case "offline":
            return .offline(
                message: _text
            )
            
        case "email":
            if let email = _body?.email {
                return .email(
                    from: email.from,
                    to: email.to,
                    subject: email.subject,
                    message: _text
                )
            }
            else {
                assertionFailure()
            }
            
        case "message":
            if let media = _media {
                let link = (media.fullURL ?? media.thumbURL)?.absoluteString ?? ""
                let name = media.name ?? link
                
                if media.type == .photo {
                    return .photo(
                        mime: media.mime,
                        name: name,
                        link: link,
                        dataSize: media.dataSize,
                        width: Int(media.originalSize.width),
                        height: Int(media.originalSize.height)
                    )
                }
                else if let conference = media.conference {
                    return .conference(
                        conference: conference
                    )
                }
                else if let story = media.story {
                    return .story(
                        story: story
                    )
                }
                else {
                    return .file(
                        mime: media.mime,
                        name: name,
                        link: link,
                        size: media.dataSize
                    )
                }
            }
            else if let call = _body?.call {
                return .call(
                    call: call
                )
            }
            else if let task = _body?.task {
                return .task(
                    task: task
                )
            }
            else if senderBot, let buttons = _body?.buttons, !buttons.isEmpty {
                let caption = _body?.text?.jv_valuable ?? text
                return .bot(message: caption, buttons: buttons, markdown: _isMarkdown)
            }
            else {
                return .text(
                    message: text
                )
            }
            
        case "transfer":
            if let transferFrom = _senderAgent, let department = _body?.transfer?.department, let transferTo = _body?.transfer?.agent {
                return .transferDepartment(
                    from: transferFrom,
                    department: department,
                    to: transferTo
                )
            }
            else if let transferFrom = _senderAgent, let transferTo = _body?.transfer?.agent {
                return .transfer(
                    from: transferFrom,
                    to: transferTo
                )
            }
            else {
                assertionFailure()
            }
            
        case "join":
            if let joinedAgent = _senderAgent {
                return .join(
                    assistant: joinedAgent,
                    by: _body?.invite?.by
                )
            }
            else {
                assertionFailure()
            }

        case "left":
            if let leftAgent = _senderAgent {
                return .left(
                    agent: leftAgent,
                    kicker: _body?.invite?.by
                )
            }
            else {
                assertionFailure()
            }
            
        case "system":
            return .text(
                message: _text
            )
            
        case "call":
            if let call = _body?.call {
                return .call(
                    call: call
                )
            }

        case "line":
            return .line

        case "reminder":
            if let task = _body?.task {
                return .task(
                    task: task
                )
            }
            
        case "comment":
            return .comment(
                message: _text
            )
            
        case "order":
            if let order = _body?.order {
                return .order(
                    email: order.email,
                    phone: order.phone,
                    subject: order.subject,
                    details: order.text,
                    button: localizer["Chat.Order.Call.Button"])
            }

        case "contact_form":
            let status = JVMessageBodyContactFormStatus(rawValue: rawText) ?? .inactive
            return .contactForm(status: status)
            
        default:
            break
//            assertionFailure()
        }
        
        return .text(
            message: _text
        )
    }
    
    var isAutomatic: Bool {
        if case .proactive = content {
            return true
        }
        else {
            return false
        }
    }
    
    var sender: JVDisplayable? {
        return senderAgent ?? senderClient ?? client
    }
    
    var senderClient: JVClient? {
        return _senderClient
    }
    
    var senderAgent: JVAgent? {
        if case .call(let call) = content {
            return call.agent
        }
        else {
            return _senderAgent
        }
    }
    
    var senderBot: Bool {
        return _senderBot
    }
    
    var senderBott: JVBot? {
        return _senderBott
    }
    
    func relativeSenderDisplayName() -> String? {
        if senderBot {
            return "bot"
        }
        else if let sender = sender, sender.jv_isValid {
            return isSystemLike ? nil : sender.displayName(kind: .relative)
        }
        else {
            return nil
        }
    }
    
    var rawText: String {
        return _text
    }
    
    var text: String {
        guard !(isDeleted) else {
            return localizer["Message.Deleted"]
        }
        
        if let media = _media {
            if let name = media.name {
                return name
            }
            else if let link = media.fullURL?.absoluteString {
                return link
            }

            return String()
        }
        else {
            if let text = _text.jv_valuable {
                return text
            }
            else if let subject = _body?.email?.subject {
                return subject
            }
            else if let details = _body?.order?.text {
                return details
            }
            else if let text = _body?.text?.jv_valuable {
                return text
            }

            return String()
        }
    }
    
    var taskStatus: JVMessageBodyTaskStatus {
        if case .task(let task) = content {
            return _body?.status.flatMap(JVMessageBodyTaskStatus.init) ?? task.status
        }
        else {
            return .unknown
        }
    }
    
    var contentHash: JVMessageContentHash {
        var hasher = Hasher()
        
        hasher.combine(type)
        hasher.combine(text)
        
        if let media = _media {
            hasher.combine(media.dataSize)
            hasher.combine(media.originalSize.width)
            hasher.combine(media.originalSize.height)
        }
        
        return JVMessageContentHash(
            ID: _ID,
            value: hasher.finalize()
        )
    }
    
    var isMarkdown: Bool {
        return _isMarkdown
    }
    
    func iconContent() -> UIImage? {
        switch content {
        case .proactive,
             .offline,
             .text,
             .comment,
             .transfer,
             .transferDepartment,
             .join,
             .left,
             .photo,
             .file,
             .line,
             .bot,
             .order,
             .contactForm:
            return nil
            
        case .story:
            return UIImage(named: "preview_ig")

        case .email:
            return UIImage(named: "preview_email")

        case .call(let call):
            switch call.type {
            case .callback: return UIImage(named: "preview_call_out")
            case .outgoing: return UIImage(named: "preview_call_out")
            case .incoming: return UIImage(named: "preview_call_in")
            case .unknown: return nil
            }

        case .task:
            return nil
            
        case .conference:
            return UIImage(named: "preview_conf")
        }
    }

    func contextImageURL(transparent: Bool) -> JMRepicItem? {
        switch content {
        case .transfer(let inviter, let assistant) where assistant.isMe:
            return inviter.metaImage(providers: nil, transparent: transparent, scale: nil)

        case .transfer(_, let assistant):
            return assistant.metaImage(providers: nil, transparent: transparent, scale: nil)

        case .join(let assistant, _):
            return assistant.metaImage(providers: nil, transparent: transparent, scale: nil)

        case .left:
            return nil

        default:
            break
        }

        guard let link = _iconLink?.jv_valuable else { return nil }
        return URL(string: link).flatMap(JMRepicItemSource.remote).flatMap {
            JMRepicItem(backgroundColor: nil, source: $0, scale: 1.0, clipping: .dual)
        }
    }
    
    var status: JVMessageStatus? {
        switch _status {
        case "sent": return JVMessageStatus.sent
        case "delivered": return JVMessageStatus.delivered
        case "seen": return JVMessageStatus.seen
        default: return nil
        }
    }
    
    var delivery: JVMessageDelivery {
        if direction != .outgoing {
            return .none
        }
        else if _ID == 0, _localID.jv_valuable != nil {
            return _sendingFailed ? .failed : .sending
        }
        else if let status = status {
            return .status(status)
        }
        else {
            return .none
        }
    }
    
    var interactiveID: String? {
        return _interactiveID
    }
    
    var hasRead: Bool {
        return _hasRead
    }
    
    var sentByMe: Bool {
        if direction != .outgoing {
            return false
        }
        else {
            return (_senderAgent?.isMe == true)
        }
    }
    
    var media: JVMessageMedia? {
        return _media
    }
    
    var call: JVMessageBodyCall? {
        return _body?.call
    }

    var order: JVMessageBodyOrder? {
        return _body?.order
    }

    var task: JVMessageBodyTask? {
        return _body?.task
    }
    
    var iconURL: URL? {
        if let link = _iconLink?.jv_valuable {
            return URL(string: link)
        }
        else {
            return nil
        }
    }
    
    var isOffline: Bool {
        return _isOffline
    }
    
    var isHidden: Bool {
        return _isHidden
    }
    
    var isDeleted: Bool {
        return _isDeleted
    }
    
    var updatedMeta: JVMessageUpdateMeta? {
        guard let agent = _updatedAgent else { return nil }
        let date = Date(timeIntervalSince1970: _updatedTimepoint)
        return JVMessageUpdateMeta(agent: agent, date: date)
    }
    
    var reactions: [JVMessageReaction] {
        guard
            let data = _reactions,
            let items = try? PropertyListDecoder().decode([JVMessageReaction].self, from: data)
            else { return [] }
        
        return items
    }
    
    var buttons: [String] {
        return _body?.buttons ?? []
    }
    
    var hasIdentity: Bool {
        return (ID > 0 || !(localID.isEmpty))
    }
    
    func obtainObjectToCopy() -> Any? {
        if let media = media {
            return media.fullURL ?? media.thumbURL
        }
        else if let call = call {
            return call.phone
        }
        else {
            return text
        }
    }
    
    func correspondsTo(chat: JVChat) -> Bool {
        if let client = _correspondsTo_getSelfClient() {
            let chatClient = _correspondsTo_getChatClient(chat: chat)
            return (client.ID == chatClient?.ID)
        }
        else {
            let selfChatId = _correspondsTo_getSelfChatId()
            let chatId = _correspondsTo_getChat(chat: chat)?.ID
            return (selfChatId == chatId)
        }
    }
    
    /**
     Some extra private methods for <func correspondsTo(chat: JVChat) Bool>
     to make the stacktrace more readable for debug purpose
     */
    
    private func _correspondsTo_getSelfChatId() -> Int? {
        return jv_isValid ? chatID : nil
    }
    
    private func _correspondsTo_getSelfClient() -> JVClient? {
        return jv_isValid ? client : nil
    }
    
    private func _correspondsTo_getChat(chat: JVChat) -> JVChat? {
        return jv_validate(chat)
    }
    
    private func _correspondsTo_getChatClient(chat: JVChat) -> JVClient? {
        return chat.jv_isValid ? jv_validate(chat.client) : nil
    }
    
    func canUpgradeStatus(to newStatus: String) -> Bool {
        return (_status != newStatus)
    }
}
