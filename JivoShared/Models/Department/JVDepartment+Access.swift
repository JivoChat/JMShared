//
//  _JVAgent+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

extension _JVDepartment {
    public var ID: Int {
        return _ID
    }
    
    public var name: String {
        return _name
    }
    
    public var icon: String {
        return _icon.jv_convertToEmojis()
    }
    
    public var brief: String {
        return _brief
    }
    
    public func corresponds(to channel: _JVChannel) -> Bool {
        return _channelsIds.contains(",\(channel.ID),")
    }
    
    public var agentsIds: [Int] {
        return _agentsIds
            .split(separator: ",")
            .filter { !$0.isEmpty }
            .map { String($0).jv_toInt() }
    }
    
    public var channel: _JVChannel? {
        return nil
    }
    
    public func displayName(kind: JVDisplayNameKind) -> String {
        return name
    }
    
    public var integration: JVChannelJoint? {
        return nil
    }
    
    public var hashedID: String {
        return "department:\(ID)"
    }
    
    public var isMe: Bool {
        return false
    }
    
    public var isAvailable: Bool {
        return true
    }
    
    public var senderType: JVSenderType {
        return .department
    }
}
