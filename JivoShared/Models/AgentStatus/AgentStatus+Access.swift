//
//  JVAgentStatus+Access.swift
//  JMShared
//
//  Created by Yulia on 01.12.2022.
//

import Foundation

extension JVAgentStatus {
    public var agentID: Int {
        return _agentID
    }
    
    public var agentStatusID: Int {
        return _agentStatusID
    }
    
    public var title: String {
        return _title
    }
    
    public var comment: String {
        return _comment
    }
    
    public var emoji: String {
        if not(_emoji.isEmpty) {
            if let emojiInt = Int(String(_emoji.split(separator: "-")[0]), radix: 16),
               let emojiUnicode = UnicodeScalar(emojiInt) {
                return String(emojiUnicode)
            }
        }
        return ""
    }
}
