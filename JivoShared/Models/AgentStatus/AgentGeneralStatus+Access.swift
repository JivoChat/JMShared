//
//  AgentGeneralStatus+Access.swift
//  JMShared
//
//  Created by Yulia on 17.11.2022.
//

import Foundation

extension JVAgentGeneralStatus {
    public var statusID: Int {
        return _statusID
    }
    
    public var title: String {
        return _title
    }
    
    public var emoji: String {
        return _emoji.convertToEmojis()
    }
    
    public var position: Int {
        return _position
    }
}
