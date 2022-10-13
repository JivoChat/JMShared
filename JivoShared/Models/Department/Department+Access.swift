//
//  JVAgent+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

extension JVDepartment: Displayable {
    public var ID: Int {
        return _ID
    }
    
    public var name: String {
        return _name
    }
    
    public var icon: String {
        return _icon.convertToEmojis()
    }
    
    public var brief: String {
        return _brief
    }
    
    public func corresponds(to channel: JVChannel) -> Bool {
        return _channelsIds.contains(",\(channel.ID),")
    }
    
    public var agentsIds: [Int] {
        return _agentsIds
            .split(separator: ",")
            .filter { !$0.isEmpty }
            .map { String($0).toInt() }
    }
    
    public var channel: JVChannel? {
        return nil
    }
    
    public func displayName(kind: DisplayNameKind) -> String {
        return name
    }
    
    public var integration: ChannelJoint? {
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
    
    public var senderType: SenderType {
        return .department
    }
    
    public func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        return JMRepicItem(
            backgroundColor: DesignBook.shared.color(usage: .contentBackground),
            source: .caption(icon, DesignBook.shared.baseEmojiFont(scale: nil)),
            scale: 1.0,
            clipping: .external
        )
    }
}
