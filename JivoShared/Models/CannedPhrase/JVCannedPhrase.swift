//
//  CannedPhrase.swift
//  JMShared
//
//  Created by Yulia on 02.11.2022.
//

import Foundation

public final class JVCannedPhrase: JVBaseModel {
    @objc dynamic public var _sessionScore: Int = 0
    @objc dynamic public var _totalScore: Int = 0
    @objc dynamic public var _message: String = ""
    @objc dynamic public var _messageHashID: String = ""
    @objc dynamic public var _timestamp: Int = 0
    @objc dynamic public var _isDeleted: Bool = false
    @objc dynamic public var _uid: String = ""
    
    public override func apply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
    
    init(sessionScore: Int,
         totalScore: Int,
         message: String,
         messageHashID: String,
         timestamp: Int,
         isDeleted: Bool,
         uid: String
    ) {
        self._sessionScore = sessionScore
        self._totalScore = totalScore
        self._message = message
        self._messageHashID = messageHashID
        self._timestamp = timestamp
        self._isDeleted = isDeleted
        self._uid = uid
    }
    
    required public override init() {
        self._sessionScore = 0
        self._totalScore = 0
        self._message = ""
        self._messageHashID = ""
        self._timestamp = 0
        self._isDeleted = false
        self._uid = ""
    }
}
public extension JVCannedPhrase {
    func construct(sessionScore: Int,
                   totalScore: Int,
                   message: String,
                   messageHashID: String,
                   timestamp: Int,
                   isDeleted: Bool,
                   uid: String) -> JVCannedPhrase {
        var phrase = JVCannedPhrase()
        phrase._sessionScore = sessionScore
        phrase._totalScore = totalScore
        phrase._message = message
        phrase._messageHashID = messageHashID
        phrase._timestamp = timestamp
        phrase._isDeleted = isDeleted
        phrase._uid = uid
        return phrase
    }
}
