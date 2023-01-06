//
//  JVAgent+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

extension JVBot: JVDisplayable {
    public var isMe: Bool {
        return false
    }
    
    public var isAvailable: Bool {
        return true
    }
    
    public var senderType: JVSenderType {
        return .bot
    }

    public var id: Int {
        return _id
    }
    
    public var channel: JVChannel? {
        return nil
    }
    
    public func metaImage(providers: JVMetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem? {
        let url = _avatarLink.flatMap(URL.init)
        let icon = UIImage(named: "avatar_bot", in: .jv_shared, compatibleWith: nil)
        let image = JMRepicItemSource.avatar(URL: url, image: icon, color: nil, transparent: transparent)
        return JMRepicItem(backgroundColor: nil, source: image, scale: scale ?? 1.0, clipping: .dual)
    }
    
    public func displayName(kind: JVDisplayNameKind) -> String {
        switch kind {
        case .original:
            return _displayName
        case .short:
            let originalName = displayName(kind: .original)
            let clearName = originalName.trimmingCharacters(in: .whitespaces)
            let slices = (clearName as NSString).components(separatedBy: .whitespaces)
            return (slices.count > 1 ? "\(slices[0]) \(slices[1].prefix(1))." : clearName)
        case .decorative:
            return displayName(kind: .original)
        case .relative:
            return displayName(kind: .original)
        }
    }
    
    public var title: String {
        return _title
    }
    
    public var integration: JVChannelJoint? {
        return nil
    }
    
    public var hashedID: String {
        return "bot:\(id)"
    }
}
