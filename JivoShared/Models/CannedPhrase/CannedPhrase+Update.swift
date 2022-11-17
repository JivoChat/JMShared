//
//  CannedPhrase+Update.swift
//  JMShared
//
//  Created by Yulia Popova on 31.10.2022.
//

import JMCodingKit

extension JVCannedPhrase {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let change = change as? CannedPhraseChange {
            _message = change.message
            _messageHashID = change.messageHashID
            _totalScore = change.totalScore
            _sessionScore = change.sessionScore
            _timestamp = change.timestamp
            _isDeleted = change.isDeleted
            _uid = change.uid
        }
    }
}

public final class CannedPhraseChange: BaseModelChange {
    public var messageHashID: String
    public var message: String
    public var timestamp: Int
    public var totalScore: Int
    public var sessionScore: Int
    public var isDeleted: Bool
    public var uid: String

    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_messageHashID", value: messageHashID)
    }
    
    public required init(json: JsonElement) {
        messageHashID = json["message_hash_id"].stringValue
        message = json["message"].stringValue
        timestamp = json["timestamp"].intValue
        totalScore = json["score"].intValue
        sessionScore = 0
        isDeleted = false
        uid = json["uid"].stringValue
        super.init(json: json)
    }

    public init(messageHashID: String,
                message: String,
                timestamp: Int,
                totalScore: Int,
                sessionScore: Int,
                isDeleted: Bool,
                uid: String) {
        self.messageHashID = messageHashID
        self.message = message
        self.timestamp = timestamp
        self.totalScore = totalScore
        self.sessionScore = sessionScore
        self.isDeleted = isDeleted
        self.uid = uid
        super.init()
    }

    public func encode() -> JsonElement {
        return JsonElement([
            "message_hash_id": messageHashID,
            "message": message,
            "timestamp": timestamp,
            "session_score": sessionScore,
            "total_score": totalScore
        ])
    }
}
