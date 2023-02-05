//
//  CannedPhrase+Access.swift
//  JMShared
//
//  Created by Yulia on 03.11.2022.
//

import Foundation
import JMCodingKit

extension _JVCannedPhrase {
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
}
