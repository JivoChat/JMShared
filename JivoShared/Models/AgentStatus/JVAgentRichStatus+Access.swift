//
//  JVAgentRichStatus+Access.swift
//  JMShared
//
//  Created by Yulia on 17.11.2022.
//

import Foundation

extension JVAgentRichStatus {
    public var statusID: Int {
        return _statusID
    }
    
    public var title: String {
        return _title
    }
    
    public var emoji: String {
        return _emoji.jv_convertToEmojis()
    }
    
    public var position: Int {
        return _position
    }
}
