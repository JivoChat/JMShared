//  
//  JVArchiveHit+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
public enum JVArchiveHitSort {
    case byTime
    case byScore
}

extension JVArchiveHit {
    public var ID: String {
        return _ID
    }
    
    public var item: JVArchiveHitItem? {
        return _chatItem ?? _callItem
    }
    
    public var chatItem: JVArchiveHitChatItem? {
        return _chatItem
    }
    
    public var callItem: JVArchiveHitCallItem? {
        return _callItem
    }
    
    public var chat: JVChat? {
        return item?.chat
    }
    
    public var duration: TimeInterval {
        return item?.duration ?? 0
    }
    
    public var latestActivityTime: Date? {
        return _latestActivityTime
    }
}
