//
//  JVMessage+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVMessage {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        func _adjustSender(type: String, ID: Int, body: JVMessageBodyGeneralChange?) {
            if let body = body, let _ = body.callID {
                _senderAgent = body.agentID.flatMap { context.agent(for: $0, provideDefault: true) }
                return
            }
            
            switch type {
            case "client":
                _senderClient = context.client(for: ID, needsDefault: false)
            case "agent":
                _senderAgent = context.agent(for: ID, provideDefault: true)
            case "system" where type == "proactive":
                _senderAgent = context.agent(for: ID, provideDefault: true)
            case "system":
                _senderAgent = _body?.call?.agent.flatMap { context.agent(for: $0.ID, provideDefault: true) }
            case "bot":
                _senderBot = true
                _senderBott = context.bot(for: ID, provideDefault: true)
            case _ where _clientID > 0:
                _senderClient = context.client(for: _clientID, needsDefault: false)
            default:
                assertionFailure()
            }
        }
        
        func _adjustBotMeta(text: String) {
            guard text.contains("⦀")
            else {
                return
            }
            
            let slices = (String(" ") + text).split(separator: "⦀")
            _text = slices.first.flatMap(String.init)?.jv_trimmed() ?? String()
            
            if _body == nil {
                _body = context.insert(of: JVMessageBody.self, with: JVMessageBodyGeneralChange(json: JsonElement()))
            }
            
            _body?._buttons = slices.dropFirst()
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .joined(separator: "\n")
        }
        
        func _adjustIncomingState(clientID: Int?) {
            if let _ = clientID ?? context.clientID(for: _chatID) {
                let value = (_senderClient.jv_hasValue || _senderAgent?.isMe == false)
                _isIncoming = value
            }
            else {
                let value = (_senderAgent?.isMe == false)
                _isIncoming = value
            }
        }
        
        func _adjustStatus(status: String?) {
            guard _status != JVMessageStatus.seen.rawValue else {
                return
            }
            
            if let status = status {
                _status = (JVMessageStatus(rawValue: status) ?? .delivered).rawValue
            }
            else {
                _status = JVMessageStatus.delivered.rawValue
            }
        }
        
        func _adjustHidden() {
            if _type == "comment", _isDeleted {
                _isHidden = true
            }
            else {
                _isHidden = false
            }
        }

        func _adjustTask(task: JVMessageBodyTask?) {
            guard let task = task else { return }
            guard let agentID = task.agent?.ID else { return }
            
            let status: String
            switch task.status {
            case .created, .updated: status = JVTaskStatus.active.rawValue
            case .completed, .deleted: status = JVTaskStatus.unknown.rawValue
            case .fired: status = JVTaskStatus.fired.rawValue
            case .unknown: status = JVTaskStatus.unknown.rawValue
            }

            _ = context.upsert(
                of: JVTask.self,
                with: JVTaskGeneralChange(
                    ID: task.taskID,
                    agentID: agentID,
                    agent: nil,
                    text: task.text,
                    createdTs: task.createdAt?.timeIntervalSince1970,
                    modifiedTs: task.updatedAt?.timeIntervalSince1970,
                    notifyTs: task.notifyAt.timeIntervalSince1970,
                    status: status
                )
            )
        }
        
        if let c = change as? JVMessageGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _date = Date(timeIntervalSince1970: TimeInterval(c.creationTS))
            _clientID = c.clientID
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatID
            _type = c.type
            _isMarkdown = c.isMarkdown
            _text = c.text.jv_trimmed()
            _body = context.insert(of: JVMessageBody.self, with: c.body, validOnly: true)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)
            
            let updatedReactions = try? PropertyListEncoder().encode(c.reactions)
            if updatedReactions != _reactions {
                _reactions = updatedReactions
                context.timelineCache.resetSize(for: UUID)
            }
            
            _isOffline = c.isOffline
            _updatedAgent = c.updatedBy.flatMap { context.agent(for: $0, provideDefault: false) }
            _updatedTimepoint = c.updatedTs ?? 0
            _isDeleted = c.isDeleted

            _adjustSender(type: c.senderType, ID: c.senderID, body: c.body)
            _adjustBotMeta(text: c.text)
            _adjustIncomingState(clientID: c.clientID)
            _adjustStatus(status: c.status)
            _adjustHidden()
        }
        else if let c = change as? JVMessageShortChange {
            if _ID == 0 { _ID = c.ID }
            
            _clientID = c.clientID ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatID
            _type = "message"
            _isMarkdown = false
            _text = c.text.jv_trimmed()
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)

            if let date = c.time.jv_parseDateUsingFullFormat() {
                _date = date
            }
            else {
                _date = Date()
            }
            
            if let senderType = c.senderType.jv_valuable {
                _adjustSender(type: senderType, ID: c.senderID, body: nil)
                _adjustBotMeta(text: c.text)
                _adjustIncomingState(clientID: nil)
                _adjustStatus(status: JVMessageStatus.delivered.rawValue)
                _adjustHidden()
            }
            else if let clientID = c.clientID {
                _adjustSender(type: "client", ID: clientID, body: nil)
                _adjustBotMeta(text: c.text)
                _adjustIncomingState(clientID: clientID)
                _adjustStatus(status: JVMessageStatus.delivered.rawValue)
                _adjustHidden()
            }
            else {
                assertionFailure()
            }
        }
        else if let c = change as? JVMessageLocalChange {
            if _ID == 0 { _ID = c.ID }
            
            _clientID = c.clientID ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _date = Date(timeIntervalSince1970: TimeInterval(c.creationTS))
            _chatID = c.chatID
            _text = c.text.jv_trimmed()
            _type = c.type
            _isMarkdown = c.isMarkdown
            _body = context.insert(of: JVMessageBody.self, with: c.body, validOnly: true)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)
            _isOffline = c.isOffline
            _updatedAgent = c.updatedBy.flatMap { context.agent(for: $0, provideDefault: false) }
            _updatedTimepoint = c.updatedTs ?? 0
            _isDeleted = c.isDeleted

            _adjustSender(type: c.senderType, ID: c.senderID, body: c.body)
            _adjustBotMeta(text: c.text)
            _adjustIncomingState(clientID: nil)
            _adjustStatus(status: JVMessageStatus.delivered.rawValue)
            _adjustHidden()
        }
        else if let c = change as? JVMessageFromClientChange {
            if _ID == 0 { _ID = c.ID }
            _date = Date()
            _clientID = c.clientID
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatID
            _type = "message"
            _isMarkdown = false
            _text = c.text.jv_trimmed()
            _senderClient = context.object(JVClient.self, primaryKey: c.clientID)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)

            _adjustBotMeta(text: c.text)
            _adjustIncomingState(clientID: nil)
            _adjustStatus(status: JVMessageStatus.delivered.rawValue)
            _adjustHidden()
        }
        else if let c = change as? JVMessageFromAgentChange {
            if _ID == 0 { _ID = c.ID }
            _clientID = context.clientID(for: c.chatID) ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _date = c.date
            _chatID = c.chatID
            _type = c.type
            _isMarkdown = c.isMarkdown
            _text = c.text.jv_trimmed()
            _body = context.insert(of: JVMessageBody.self, with: c.body, validOnly: true)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)
            _updatedAgent = c.updatedBy.flatMap { context.agent(for: $0, provideDefault: false) }
            _updatedTimepoint = c.updatedTs ?? 0
            _isDeleted = c.isDeleted

            _adjustSender(type: c.senderType, ID: c.senderID, body: c.body)
            _adjustBotMeta(text: c.text)
            _adjustIncomingState(clientID: nil)
            _adjustTask(task: _body?.task)
            _adjustStatus(status: JVMessageStatus.delivered.rawValue)
            _adjustHidden()
        }
        else if let c = change as? JVMessageStateChange {
            if _ID == 0 { _ID = c.globalID }
            _date = c.date ?? _date
            _sendingDate = 0
            _sendingFailed = false
            _adjustStatus(status: c.status ?? _status)
        }
        else if let c = change as? JVMessageGeneralSystemChange {
            _clientID = c.clientID ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatID
            _date = Date(timeIntervalSince1970: c.creationTS)
            _orderingIndex = 1
            _text = c.text.jv_trimmed()
            _type = "system"
            _isMarkdown = false
            _interactiveID = c.interactiveID
            _iconLink = c.iconLink
            
            _adjustHidden()
        }
        else if let c = change as? JVMessageOutgoingChange {
            _localID = c.localID
            _date = c.date
            _clientID = c.clientID ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatID
            _isIncoming = false
            _type = c.type
            _isMarkdown = false
            _status = String()
            
            switch c.contents {
            case .text(let text):
                _text = text.jv_trimmed()
                
            case .comment(let text):
                _text = text.jv_trimmed()
                
            case .email:
                abort()
                
            case .photo(let mime, let name, let link, let dataSize, let width, let height):
                _text = "🖼 " + name.jv_trimmed()
                
                _media = context.insert(
                    of: JVMessageMedia.self,
                    with: JVMessageMediaGeneralChange(
                        type: "photo",
                        mime: mime,
                        name: name,
                        link: link,
                        size: dataSize,
                        width: width,
                        height: height
                    )
                )
                
            case .file(let mime, let name, let link, let size):
                _text = "📄 " + name.jv_trimmed()
                
                _media = context.insert(
                    of: JVMessageMedia.self,
                    with: JVMessageMediaGeneralChange(
                        type: "document",
                        mime: mime,
                        name: name,
                        link: link,
                        size: size,
                        width: 0,
                        height: 0
                    )
                )
                
            case .contactForm(let status):
                _text = status.rawValue
                
            case .proactive, .offline, .transfer, .transferDepartment, .join, .left, .call, .line, .task, .bot, .order, .conference, .story:
                assertionFailure()
            }
            
            _adjustSender(type: c.senderType, ID: c.senderID, body: nil)
            _adjustHidden()
        }
        else if let c = change as? JVMessageSendingChange {
            _sendingDate = c.sendingDate ?? _sendingDate
            _sendingFailed = c.sendingFailed ?? _sendingFailed
        }
        else if let c = change as? JVMessageReadChange {
            _hasRead = c.hasRead
        }
        else if let c = change as? JVMessageTextChange {
            if text != c.text.jv_trimmed() {
                _text = c.text.jv_trimmed()
            }
        }
        else if let c = change as? JVMessageReactionChange {
            var payload = reactions
            
            let reactionIndex = payload.firstIndex(
                where: { $0.emoji == c.emoji }
            )
            
            let reactorIndex = reactionIndex.flatMap { index in
                payload[index].reactors.firstIndex(
                    where: { $0.subjectKind == c.fromKind && $0.subjectID == c.fromID }
                )
            }
            
            if c.deleted {
                if let reactionIndex = reactionIndex {
                    var reactors = payload[reactionIndex].reactors
                    
                    if let reactorIndex = reactorIndex {
                        reactors.remove(at: reactorIndex)
                    }
                    
                    if reactors.isEmpty {
                        payload.remove(at: reactionIndex)
                    }
                    else {
                        payload[reactionIndex].reactors = reactors
                    }
                }
            }
            else {
                let reactor = JVMessageReactor(subjectKind: c.fromKind, subjectID: c.fromID)
                
                if let reactionIndex = reactionIndex {
                    var reactors = payload[reactionIndex].reactors
                    
                    if reactorIndex == nil {
                        reactors.append(reactor)
                    }
                    
                    payload[reactionIndex].reactors = reactors
                }
                else {
                    let reaction = JVMessageReaction(emoji: c.emoji, reactors: [reactor])
                    payload.append(reaction)
                }
            }
            
            _reactions = try? PropertyListEncoder().encode(payload)
            
            context.timelineCache.resetSize(for: UUID)
        }
        else if let c = change as? JVMessageSdkAgentChange {
            if _ID == 0 { _ID = c.ID }
            _clientID = context.clientID(for: c.chat.ID) ?? 0
            _client = context.client(for: _clientID, needsDefault: false)
            _date = c.creationDate
            _chatID = c.chat.ID
            _type = c.type
            _isMarkdown = c.isMarkdown
            _text = c.text.jv_trimmed()
            _body = context.insert(of: JVMessageBody.self, with: c.body, validOnly: true)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)
            _updatedAgent = c.updatedBy.flatMap { context.agent(for: $0, provideDefault: false) }
            _updatedTimepoint = c.updateDate?.timeIntervalSince1970 ?? 0
            _isDeleted = c.isDeleted

            _adjustSender(type: c.senderType, ID: c.agent.ID, body: c.body)
            _adjustIncomingState(clientID: nil)
            _adjustTask(task: _body?.task)
            _adjustStatus(status: JVMessageStatus.delivered.rawValue)
            _adjustHidden()
        }
        else if let c = change as? JVMessageSdkClientChange {
            if ID == 0 { _ID = c.id }
            if localID == "" { _localID = c.localId }
            _date = c.date
            _clientID = c.clientId
            _client = context.client(for: _clientID, needsDefault: false)
            _chatID = c.chatId
            _type = c.type
            _isMarkdown = c.isMarkdown
            _text = c.text
            _senderClient = context.object(JVClient.self, primaryKey: clientID)
            _media = context.insert(of: JVMessageMedia.self, with: c.media, validOnly: true)
            
            _adjustIncomingState(clientID: nil)
            _adjustStatus(status: JVMessageStatus.delivered.rawValue)
            _adjustHidden()
        }
        else if let c = change as? JVSdkMessageStatusChange {
            if _ID == 0 { _ID = c.id }
            _status = c.status?.rawValue ?? ""
            if let date = c.date {
                _date = date
            }
        }
        else if let c = change as? JVSdkMessageAtomChange {
            c.updates.forEach { update in
                switch update {
                case let .id(newValue):
                    if _ID == 0 && _ID != newValue {
                        _ID = newValue
                    }
                    
                    _isMarkdown = true
                    
                case let .localId(newValue):
                    if _localID != newValue {
                        _localID = newValue
                    }
                    
                case let .text(newValue):
                    if _text != newValue {
                        _text = newValue
                    }
                    _adjustBotMeta(text: newValue)

                case let .date(newValue):
                    if _date != newValue {
                        _date = newValue
                    }
                    
                case let .status(newValue):
                    if _status != newValue.rawValue {
                        _status = newValue.rawValue
                    }
                    
                case let .chatId(newValue):
                    if _chatID != newValue {
                        _chatID = newValue
                    }
                    
                case let .media(newValue):
                    let media = context.insert(of: JVMessageMedia.self, with: newValue, validOnly: true)
                    if _media?._UUID != media?._UUID {
                        _media = media
                    }
                    
                case let .sender(senderType):
                    switch senderType {
                    case let .client(id):
                        let client = context.client(for: id, needsDefault: true)
                        if _senderClient?._UUID != client?._UUID {
                            _senderClient = client
                        }
                        
                    case let .agent(id, displayNameUpdate):
                        let existingAgent = context.agent(for: id, provideDefault: false)
                        let agent = existingAgent ?? { () -> JVAgent? in
                            let defaultAgent = context.agent(for: id, provideDefault: true)
                            if case let JVMessagePropertyUpdate.Sender.DisplayNameUpdatingLogic.updating(with: newValue) = displayNameUpdate {
                                newValue.flatMap { defaultAgent?._displayName = $0 }
                            }
                            return defaultAgent
                        }()
                        
                        _senderBot = (id < 0)
                        
                        if _senderAgent?._UUID != agent?._UUID {
                            _senderAgent = agent
                        }
                    }
                    
                case let .typeInitial(newValue):
                    if _type == String() {
                        _type = newValue.rawValue
                    }
                
                case let .typeOverwrite(newValue):
                    if _type != newValue.rawValue {
                        _type = newValue.rawValue
                    }
                
                case let .isHidden(newValue):
                    if _isHidden != newValue {
                        _isHidden = newValue
                    }
                    
                case let .isIncoming(newValue):
                    if _isIncoming != newValue {
                        _isIncoming = newValue
                    }
                    
                case let .isSendingFailed(newValue):
                    if _sendingFailed != newValue {
                        _sendingFailed = newValue
                    }
                }
            }
        }
        else if let c = change as? JVSDKMessageOfflineChange {
            _localID = c.localId
            _date = c.date
            _type = c.type
            
            if case let .offline(text) = c.content {
                _text = text
            }
        }
    }
    
    public func performDelete(inside context: JVIDatabaseContext) {
        context.customRemove(objects: [_body, _media].jv_flatten(), recursive: true)
    }
}

open class JVMessageBaseGeneralChange: JVBaseModelChange, Comparable {
    public let ID: Int
    public let creationTS: TimeInterval
    public let body: JVMessageBodyGeneralChange?
    public let isOffline: Bool
    
    open override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public init(ID: Int, creationTS: TimeInterval, body: JVMessageBodyGeneralChange?) {
        self.ID = ID
        self.creationTS = creationTS
        self.body = body
        self.isOffline = false
        super.init()
    }
    
    required public init(json: JsonElement) {
        ID = json["msg_id"].intValue
        creationTS = json["created_ts"].doubleValue
        body = json["body"].parse()
        isOffline = (json["source"]["channel_type"].string == "offline")
        super.init(json: json)
    }
    
    public func copy(ID: Int) -> JVMessageBaseGeneralChange {
        abort()
    }
}

open class JVMessageExtendedGeneralChange: JVMessageBaseGeneralChange {
    public let type: String
    public let isMarkdown: Bool
    public let senderType: String
    
    public init(
         ID: Int,
         creationTS: TimeInterval,
         body: JVMessageBodyGeneralChange?,
         type: String,
         isMarkdown: Bool,
         senderType: String
    ) {
        self.type = type
        self.isMarkdown = isMarkdown
        self.senderType = senderType
        
        super.init(
            ID: ID,
            creationTS: creationTS,
            body: body
        )
    }

    required public init(json: JsonElement) {
        type = json["type"].stringValue
        isMarkdown = json["is_markdown"].boolValue
        senderType = json["from"].stringValue
        super.init(json: json)
    }
    
    open override var isValid: Bool {
        if type == "call", !(body?.isValidCall == true) {
            return false
        }
        
        return validateMessage(senderType: senderType, type: type)
    }
}

public final class JVMessageGeneralChange: JVMessageExtendedGeneralChange {
    public let clientID: Int
    public let chatID: Int
    public let senderID: Int
    public let text: String
    public let status: String
    public let media: JVMessageMediaGeneralChange?
    public let updatedBy: Int?
    public let updatedTs: TimeInterval?
    public let reactions: [JVMessageReaction]
    public let isDeleted: Bool
    
    public override var primaryValue: Int {
        abort()
    }
    
    public init(ID: Int,
         clientID: Int,
         chatID: Int,
         type: String,
         isMarkdown: Bool,
         senderID: Int,
         senderType: String,
         text: String,
         creationTS: TimeInterval,
         status: String,
         body: JVMessageBodyGeneralChange?,
         media: JVMessageMediaGeneralChange?,
         updatedBy: Int?,
         updatedTs: TimeInterval?,
         reactions: [JVMessageReaction],
         isDeleted: Bool) {
        self.clientID = clientID
        self.chatID = chatID
        self.senderID = senderID
        self.text = text
        self.status = status
        self.media = media
        self.updatedBy = updatedBy
        self.updatedTs = updatedTs
        self.reactions = reactions
        self.isDeleted = isDeleted
        
        super.init(
            ID: ID,
            creationTS: creationTS,
            body: body,
            type: type,
            isMarkdown: isMarkdown,
            senderType: senderType
        )
    }
    
    required public init(json: JsonElement) {
        clientID = json["client_id"].intValue
        chatID = json["chat_id"].intValue
        senderID = json["from_id"].intValue
        text = json["text"].stringValue
        status = extractStatus(primary: json["statuses"].arrayValue, secondary: json["status"])
        media = json["media"].parse()
        updatedBy = json["updated_by"].int
        updatedTs = json["updated_ts"].double
        reactions = parseReactions(json["reactions"])
        isDeleted = json["deleted"].boolValue
        super.init(json: json)
    }
    
    public override var isValid: Bool {
        if type == "message", media?.type == "conference", senderType == "agent" {
            return false
        }
        
        return super.isValid
    }
    
    public var callID: String? {
        return body?.callID
    }
    
    public override func copy(ID: Int) -> JVMessageBaseGeneralChange {
        return JVMessageGeneralChange(
            ID: ID,
            clientID: clientID,
            chatID: chatID,
            type: type,
            isMarkdown: isMarkdown,
            senderID: senderID,
            senderType: senderType,
            text: text,
            creationTS: creationTS,
            status: status,
            body: body,
            media: media,
            updatedBy: updatedBy,
            updatedTs: updatedTs,
            reactions: reactions,
            isDeleted: isDeleted)
    }
    
    public func copy(clientID: Int) -> JVMessageGeneralChange {
        return JVMessageGeneralChange(
            ID: ID,
            clientID: clientID,
            chatID: chatID,
            type: type,
            isMarkdown: isMarkdown,
            senderID: senderID,
            senderType: senderType,
            text: text,
            creationTS: creationTS,
            status: status,
            body: body,
            media: media,
            updatedBy: updatedBy,
            updatedTs: updatedTs,
            reactions: reactions,
            isDeleted: isDeleted)
    }
}

public final class JVMessageShortChange: JVBaseModelChange {
    public let ID: Int
    public let clientID: Int?
    public let chatID: Int
    public let senderType: String
    public let senderID: Int
    public let text: String
    public let isMarkdown: Bool
    public let time: String
    public let media: JVMessageMediaGeneralChange?

    public override var primaryValue: Int {
        abort()
    }
    
    public override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public override var isValid: Bool {
        guard ID > 0 else { return false }
        return true
    }
    
    public init(ID: Int,
         clientID: Int?,
         chatID: Int,
         senderType: String,
         senderID: Int,
         text: String,
         isMarkdown: Bool,
         time: String,
         media: JVMessageMediaGeneralChange?) {
        self.ID = ID
        self.clientID = clientID
        self.chatID = chatID
        self.senderType = senderType
        self.senderID = senderID
        self.text = text
        self.isMarkdown = isMarkdown
        self.time = time
        self.media = media
        super.init()
    }

    required public init(json: JsonElement) {
        ID = json["msg_id"].intValue
        clientID = json["client_id"].int
        chatID = json["chat_id"].intValue
        senderType = json["from"].stringValue
        senderID = json["from_id"].intValue
        text = json["message"].string ?? json["text"].stringValue
        isMarkdown = json["is_markdown"].boolValue
        time = json["time"].stringValue
        media = json["media"].parse()
        super.init(json: json)
    }
    
    public func copy(clientID: Int?) -> JVMessageShortChange {
        return JVMessageShortChange(
            ID: ID,
            clientID: clientID,
            chatID: chatID,
            senderType: senderType,
            senderID: senderID,
            text: text,
            isMarkdown: isMarkdown,
            time: time,
            media: media)
    }
}

public final class JVMessageLocalChange: JVMessageExtendedGeneralChange {
    public let clientID: Int?
    public let chatID: Int
    public let senderID: Int
    public let text: String
    public let media: JVMessageMediaGeneralChange?
    public let updatedBy: Int?
    public let updatedTs: TimeInterval?
    public let isDeleted: Bool

    public override var primaryValue: Int {
        abort()
    }
    
    public init(ID: Int,
         clientID: Int?,
         chatID: Int,
         type: String,
         isMarkdown: Bool,
         senderID: Int,
         senderType: String,
         text: String,
         creationTS: TimeInterval,
         body: JVMessageBodyGeneralChange?,
         media: JVMessageMediaGeneralChange?,
         isOffline: Bool,
         updatedBy: Int?,
         updatedTs: TimeInterval?,
         isDeleted: Bool) {
        self.clientID = clientID
        self.chatID = chatID
        self.senderID = senderID
        self.text = text
        self.media = media
        self.updatedBy = updatedBy
        self.updatedTs = updatedTs
        self.isDeleted = isDeleted
        
        super.init(
            ID: ID,
            creationTS: creationTS,
            body: body,
            type: type,
            isMarkdown: isMarkdown,
            senderType: senderType
        )
    }
    
    required public init(json: JsonElement) {
        clientID = nil
        chatID = json["chat_id"].intValue
        senderID = json["from_id"].intValue
        text = json["text"].stringValue
        media = json["media"].parse()
        updatedBy = json["updated_by"].int
        updatedTs = json["updated_ts"].double
        isDeleted = json["deleted"].boolValue
        super.init(json: json)
    }
    
    public override func copy(ID: Int) -> JVMessageLocalChange {
        return JVMessageLocalChange(
            ID: ID,
            clientID: clientID,
            chatID: chatID,
            type: type,
            isMarkdown: isMarkdown,
            senderID: senderID,
            senderType: senderType,
            text: text,
            creationTS: creationTS,
            body: body,
            media: media,
            isOffline: isOffline,
            updatedBy: updatedBy,
            updatedTs: updatedTs,
            isDeleted: isDeleted)
    }

    public func attach(clientID: Int) -> JVMessageLocalChange {
        return JVMessageLocalChange(
            ID: ID,
            clientID: clientID,
            chatID: chatID,
            type: type,
            isMarkdown: isMarkdown,
            senderID: senderID,
            senderType: senderType,
            text: text,
            creationTS: creationTS,
            body: body,
            media: media,
            isOffline: isOffline,
            updatedBy: updatedBy,
            updatedTs: updatedTs,
            isDeleted: isDeleted)
    }
}

public final class JVMessageOutgoingChange: JVBaseModelChange {
    public let localID: String
    public let date: Date
    public let clientID: Int?
    public let chatID: Int
    public let type: String
    public let contents: JVMessageContent
    public let senderType: String
    public let senderID: Int
    
    public init(localID: String,
         date: Date,
         clientID: Int?,
         chatID: Int,
         type: String,
         contents: JVMessageContent,
         senderType: String,
         senderID: Int) {
        self.localID = localID
        self.date = date
        self.clientID = clientID
        self.chatID = chatID
        self.type = type
        self.contents = contents
        self.senderType = senderType
        self.senderID = senderID
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class JVMessageFromClientChange: JVBaseModelChange {
    public let ID: Int
    public let channelID: Int
    public let clientID: Int
    public let chatID: Int
    public let text: String
    public let media: JVMessageMediaGeneralChange?

    public override var primaryValue: Int {
        abort()
    }
    
    public override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public init(ID: Int, channelID: Int, clientID: Int, chatID: Int, text: String, media: JVMessageMediaGeneralChange?) {
        self.ID = ID
        self.channelID = channelID
        self.clientID = clientID
        self.chatID = chatID
        self.text = text
        self.media = media
        super.init()
    }
    
    required public init(json: JsonElement) {
        ID = json["msg_id"].intValue
        channelID = json["widget_id"].intValue
        clientID = json["client_id"].intValue
        chatID = json["chat_id"].intValue
        text = json["message"].stringValue
        media = json["media"].parse()
        super.init(json: json)
    }
    
    public func copy(ID: Int) -> JVMessageFromClientChange {
        return JVMessageFromClientChange(
            ID: ID,
            channelID: channelID,
            clientID: clientID,
            chatID: chatID,
            text: text,
            media: media
        )
    }
}

public final class JVMessageFromAgentChange: JVMessageExtendedGeneralChange {
    public let clientID: Int?
    public let senderID: Int
    public let chatID: Int
    public let date: Date?
    public let text: String
    public let media: JVMessageMediaGeneralChange?
    public let updatedBy: Int?
    public let updatedTs: TimeInterval?
    public let isDeleted: Bool

    public override var primaryValue: Int {
        abort()
    }
    
    public init(ID: Int,
         creationTS: TimeInterval,
         clientID: Int?,
         type: String,
         isMarkdown: Bool,
         senderType: String,
         senderID: Int,
         chatID: Int,
         date: Date?,
         text: String,
         body: JVMessageBodyGeneralChange?,
         media: JVMessageMediaGeneralChange?,
         updatedBy: Int?,
         updatedTs: TimeInterval?,
         isDeleted: Bool) {
        self.clientID = clientID
        self.senderID = senderID
        self.chatID = chatID
        self.date = date
        self.text = text
        self.media = media
        self.updatedBy = updatedBy
        self.updatedTs = updatedTs
        self.isDeleted = isDeleted
        
        super.init(
            ID: ID,
            creationTS: creationTS,
            body: body,
            type: type,
            isMarkdown: isMarkdown,
            senderType: senderType
        )
    }
    
    required public init(json: JsonElement) {
        clientID = json["client_id"].int
        senderID = json["from_id"].intValue
        chatID = json["chat_id"].intValue
        date = json["created_ts"].double.flatMap { Date(timeIntervalSince1970: $0) }
        text = json["text"].stringValue
        media = json["media"].parse()
        updatedBy = json["updated_by"].int
        updatedTs = json["updated_ts"].double
        isDeleted = json["deleted"].boolValue
        super.init(json: json)
    }
    
    public override func copy(ID: Int) -> JVMessageFromAgentChange {
        return JVMessageFromAgentChange(
            ID: ID,
            creationTS: creationTS,
            clientID: clientID,
            type: type,
            isMarkdown: isMarkdown,
            senderType: senderType,
            senderID: senderID,
            chatID: chatID,
            date: date,
            text: text,
            body: body,
            media: media,
            updatedBy: updatedBy,
            updatedTs: updatedTs,
            isDeleted: isDeleted)
    }
}

public final class JVMessageStateChange: JVBaseModelChange {
    public let localID: String?
    public let globalID: Int
    public let chatID: Int?
    public let agentID: Int?
    public let status: String?
    public let date: Date?
    
    public override var primaryValue: Int {
        abort()
    }
    
    public override var integerKey: JVDatabaseContextMainKey<Int>? {
        if globalID > 0 {
            return JVDatabaseContextMainKey(key: "_ID", value: globalID)
        }
        else {
            return nil
        }
    }
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        if let localID = localID {
            return JVDatabaseContextMainKey(key: "_localID", value: localID)
        }
        else {
            return nil
        }
    }
    public init(globalID: Int, date: Date?) {
        self.localID = nil
        self.globalID = globalID
        self.chatID = nil
        self.agentID = nil
        self.status = nil
        self.date = date
        super.init()
    }
    
    required public init(json: JsonElement) {
        localID = json["private_id"].string
        globalID = json["msg_id"].intValue
        chatID = json["chat_id"].int
        agentID = json["agent_id"].int
        status = extractStatus(primary: json["statuses"].arrayValue, secondary: json["status"])
        date = nil
        super.init(json: json)
    }
}

public final class JVMessageGeneralSystemChange: JVMessageBaseGeneralChange {
    public let clientID: Int?
    public let chatID: Int
    public let text: String
    public let interactiveID: String?
    public let iconLink: String?
    
    public init(clientID: Int?, chatID: Int, date: Date, text: String, interactiveID: String?, iconLink: String?) {
        self.clientID = clientID
        self.chatID = chatID
        self.text = text
        self.interactiveID = interactiveID
        self.iconLink = iconLink
        super.init(ID: 0, creationTS: date.timeIntervalSince1970, body: nil)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
    
    public override func copy(ID: Int) -> JVMessageBaseGeneralChange {
        return self
    }
}

public final class JVMessageSendingChange: JVBaseModelChange {
    public let localID: String
    public let sendingDate: TimeInterval?
    public let sendingFailed: Bool?
    
    public override var primaryValue: Int {
        abort()
    }
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey(key: "_localID", value: localID)
    }
    
    public init(localID: String, sendingDate: TimeInterval?, sendingFailed: Bool?) {
        self.localID = localID
        self.sendingDate = sendingDate
        self.sendingFailed = sendingFailed
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class JVMessageReadChange: JVBaseModelChange {
    public let ID: Int
    public let hasRead: Bool
    
    public override var primaryValue: Int {
        abort()
    }
    
    public override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public init(ID: Int, hasRead: Bool) {
        self.ID = ID
        self.hasRead = hasRead
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class JVMessageReactionChange: JVBaseModelChange {
    public let chatID: Int
    public let messageID: Int
    public let emoji: String
    public let fromKind: String
    public let fromID: Int
    public let deleted: Bool
    
    public override var isValid: Bool {
        guard let _ = emoji.jv_valuable else { return false }
        return true
    }

    public override var primaryValue: Int {
        abort()
    }
    
    public override var integerKey: JVDatabaseContextMainKey<Int>? {
        return JVDatabaseContextMainKey(key: "_ID", value: messageID)
    }
    
    required public init(json: JsonElement) {
        chatID = json["chat_id"].intValue
        messageID = json["to_msg_id"].intValue
        emoji = json["icon"].string?.jv_convertToEmojis() ?? String()
        fromKind = json["from"].stringValue
        fromID = json["from_id"].intValue
        deleted = json["deleted"].boolValue
        super.init(json: json)
    }
}

public final class JVMessageTextChange: JVBaseModelChange {
    public let UUID: String
    public let text: String
    
    public override var primaryValue: Int {
        abort()
    }
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey(key: "_UUID", value: UUID)
    }
    
    public init(UUID: String, text: String) {
        self.UUID = UUID
        self.text = text
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

open class JVMessageSdkAgentChange: JVMessageExtendedGeneralChange {
    public let agent: JVAgent
    public let chat: JVChat
    public let creationDate: Date?
    public let text: String
    public let media: JVMessageMediaGeneralChange?
    public let updatedBy: Int?
    public let updateDate: Date?
    public let isDeleted: Bool

    open override var primaryValue: Int {
        abort()
    }
    
    public init(id: Int,
         agent: JVAgent,
         chat: JVChat,
         text: String,
         body: JVMessageBodyGeneralChange? = nil,
         media: JVMessageMediaGeneralChange? = nil,
         type: JVMessageType,
         isMarkdown: Bool = false,
         creationDate: Date?,
         updatedBy: Int? = nil,
         updateDate: Date? = nil,
         isDeleted: Bool = false
    ) {
        self.agent = agent
        self.chat = chat
        self.creationDate = creationDate
        self.text = text
        self.media = media
        self.updatedBy = updatedBy
        self.updateDate = updateDate
        self.isDeleted = isDeleted
        
        super.init(
            ID: id,
            creationTS: creationDate?.timeIntervalSince1970 ?? TimeInterval.zero,
            body: body,
            type: type.rawValue,
            isMarkdown: isMarkdown,
            senderType: JVSenderType.agent.rawValue
        )
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

open class JVMessageSdkClientChange: JVMessageExtendedGeneralChange {
    public let id: Int
    public let localId: String
    public let channelId: Int
    public let clientId: Int
    public let chatId: Int
    public let text: String
    public let date: Date
    public let media: JVMessageMediaGeneralChange?

    open override var primaryValue: Int {
        abort()
    }
    
    public init(id: Int,
         localId: String,
         channelId: Int,
         clientId: Int,
         chatId: Int,
         text: String,
         date: Date,
         media: JVMessageMediaGeneralChange?
    ) {
        self.id = id
        self.localId = localId
        self.channelId = channelId
        self.clientId = clientId
        self.chatId = chatId
        self.text = text
        self.date = date
        self.media = media
        
        super.init(ID: id, creationTS: date.timeIntervalSince1970, body: nil, type: JVMessageType.message.rawValue, isMarkdown: false, senderType: JVSenderType.client.rawValue)
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

open class JVSdkMessageStatusChange: JVBaseModelChange {
    public let id: Int
    public let localId: String
    public let status: JVMessageStatus?
    public let date: Date?
    
    open override var integerKey: JVDatabaseContextMainKey<Int>? {
        return id != 0 && localId.isEmpty
            ? JVDatabaseContextMainKey(key: "_ID", value: id)
            : nil
    }
    
    open override var stringKey: JVDatabaseContextMainKey<String>? {
        return !(localId.isEmpty)
            ? JVDatabaseContextMainKey(key: "_localID", value: localId)
            : nil
    }
    
    public init(id: Int = 0, localId: String = "", status: JVMessageStatus?, date: Date? = nil) {
        self.id = id
        self.localId = localId
        self.status = status
        self.date = date
        
        super.init()
    }
    
    required public init(json: JsonElement) {
        abort()
    }
}

public enum JVMessagePropertyUpdate {
    public enum Sender {
        public enum DisplayNameUpdatingLogic {
            case updating(with: String?)
            case withoutUpdate
        }
        
        case client(withId: Int)
        case agent(withId: Int, andDisplayName: DisplayNameUpdatingLogic = .withoutUpdate)
    }
    
    case id(Int)
    case localId(String)
    case text(String)
    case date(Date)
    case status(JVMessageStatus)
    case chatId(Int)
    case media(JVMessageMediaGeneralChange)
    case sender(Sender)
    case typeInitial(JVMessageType)
    case typeOverwrite(JVMessageType)
    case isHidden(Bool)
    case isIncoming(Bool)
    case isSendingFailed(Bool)
}

public enum JVSdkMessageAtomChangeInitError: LocalizedError {
    case idIsZero
    case localIdIsEmptyString
    
    public var errorDescription: String? {
        switch self {
        case .idIsZero:
            return "'id' parameter you passed to initializator is equal to zero. It should has some other value."
        case .localIdIsEmptyString:
            return "'localId' parameter you passed to initializator is equal to empty string. It should has some other value."
        }
    }
}

open class JVSdkMessageAtomChange: JVBaseModelChange {
    let id: Int
    let localId: String
    let updates: [JVMessagePropertyUpdate]
    
    public override var primaryValue: Int {
        abort()
    }
    
    open override var integerKey: JVDatabaseContextMainKey<Int>? {
        return id != 0 && localId.isEmpty ? JVDatabaseContextMainKey(key: "_ID", value: id) : nil
    }
    
    open override var stringKey: JVDatabaseContextMainKey<String>? {
        return !localId.isEmpty ? JVDatabaseContextMainKey(key: "_localID", value: localId) : nil
    }
    
    public convenience init(id: Int, updates: [JVMessagePropertyUpdate]) throws {
        guard id != 0 else {
            throw JVSdkMessageAtomChangeInitError.idIsZero
        }
        self.init(id: id, localId: String(), updates: updates)
    }
    
    public convenience init(localId: String, updates: [JVMessagePropertyUpdate]) throws {
        guard localId != String() else {
            throw JVSdkMessageAtomChangeInitError.localIdIsEmptyString
        }
        
        if localId.contains(".") {
            let globalId = localId.components(separatedBy: ".").first ?? localId
            self.init(id: globalId.jv_toInt(), localId: String(), updates: updates)
        }
        else {
            self.init(id: 0, localId: localId, updates: updates)
        }
    }
    
    private init(id: Int, localId: String, updates: [JVMessagePropertyUpdate]) {
        self.id = id
        self.localId = localId
        self.updates = updates
        
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public class JVSDKMessageOfflineChange: JVBaseModelChange {
    let localId = JVSDKMessageOfflineChange.id
    let date = Date()
    let type = "offline"
    
    let content: JVMessageContent
    
    public override var primaryValue: Int {
        abort()
    }
    
    open override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey<String>(key: "_localID", value: localId)
    }
    
    public init(message: String) {
        content = .offline(message: message)
        
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public extension JVSDKMessageOfflineChange {
    static let id = "OFFLINE_MESSAGE"
}

fileprivate func validateMessage(senderType: String, type: String) -> Bool {
    let commonSupported = ["proactive", "email", "message", "transfer", "system", "call", "line", "reminder", "comment", "keyboard", "order"]
    if commonSupported.contains(type) {
        return true
    }
    
    let agentSupported = ["join", "left"]
    if senderType == "agent", agentSupported.contains(type) {
        return true
    }

    return false
}

fileprivate func parseReactions(_ root: JsonElement) -> [JVMessageReaction] {
    return root.ordictValue.compactMap { (emocode, reactors) in
        JVMessageReaction(
            emoji: emocode.jv_convertToEmojis(),
            reactors: reactors.arrayValue.compactMap { item in
                guard let subjectKind = item["type"].string else { return nil }
                guard let subjectID = item["id"].int else { return nil }
                return JVMessageReactor(subjectKind: subjectKind, subjectID: subjectID)
            })
    }
}

public func ==(lhs: JVMessageBaseGeneralChange, rhs: JVMessageBaseGeneralChange) -> Bool {
    if lhs.ID > 0, rhs.ID > 0 {
        return (lhs.ID == rhs.ID && lhs.creationTS == rhs.creationTS)
    }
    else {
        return (lhs.creationTS == rhs.creationTS)
    }
}

public func <(lhs: JVMessageBaseGeneralChange, rhs: JVMessageBaseGeneralChange) -> Bool {
    if lhs.ID > 0, rhs.ID > 0 {
        return (lhs.creationTS < rhs.creationTS || lhs.ID < rhs.ID)
    }
    else {
        return (lhs.creationTS < rhs.creationTS)
    }
}

public func <=(lhs: JVMessageBaseGeneralChange, rhs: JVMessageBaseGeneralChange) -> Bool {
    if lhs.ID > 0, rhs.ID > 0 {
        return (lhs.creationTS <= rhs.creationTS || lhs.ID <= rhs.ID)
    }
    else {
        return (lhs.creationTS <= rhs.creationTS)
    }
}

public func >=(lhs: JVMessageBaseGeneralChange, rhs: JVMessageBaseGeneralChange) -> Bool {
    if lhs.ID > 0, rhs.ID > 0 {
        return (lhs.creationTS >= rhs.creationTS || lhs.ID >= rhs.ID)
    }
    else {
        return (lhs.creationTS >= rhs.creationTS)
    }
}

public func >(lhs: JVMessageBaseGeneralChange, rhs: JVMessageBaseGeneralChange) -> Bool {
    if lhs.ID > 0, rhs.ID > 0 {
        return (lhs.creationTS > rhs.creationTS || lhs.ID > rhs.ID)
    }
    else {
        return (lhs.creationTS > rhs.creationTS)
    }
}

fileprivate func standartizedMessageType(_ type: String) -> String {
    if type == "clientMessage" {
        return "message"
    }
    else {
        return type
    }
}

fileprivate func extractStatus(primary: [JsonElement], secondary: JsonElement) -> String {
    if let item = primary.first(where: { $0["channel_type"] != "rmo" }) {
        return item["status"].stringValue
    }
    
    if let item = primary.first(where: { $0["channel_type"] == "rmo" }) {
        return item["status"].stringValue
    }
    
    return secondary.stringValue
}
