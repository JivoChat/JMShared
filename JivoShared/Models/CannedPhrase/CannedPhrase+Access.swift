//
//  CannedPhrase+Access.swift
//  JMShared
//
//  Created by Yulia on 03.11.2022.
//

import Foundation
import JMCodingKit

extension JVCannedPhrase {
    public var message: String {
        return _message
    }
    
    public var messageHashID: String {
        return _messageHashID
    }
    
    public var timestamp: Int {
        return _timestamp
    }
    
    public var sessionScore: Int {
        return _sessionScore
    }
    
    public var totalScore: Int {
        return _totalScore
    }
    
    public var isDeleted: Bool {
        return _isDeleted
    }
    
    public var uid: String {
        return _uid
    }
    
    public func export() -> CannedPhraseChange {
        return CannedPhraseChange(
            messageHashID: _messageHashID,
            message: _message,
            timestamp: _timestamp,
            totalScore: _totalScore,
            sessionScore: _sessionScore,
            isDeleted: _isDeleted,
            uid: _uid
        )
    }
    
    public func encode() -> JsonElement {
        return JsonElement(
            [
                "message_hash_id": _messageHashID,
                "message": _message,
                "session_score": _sessionScore,
                "total_score": _totalScore
            ]
        )
    }
}
