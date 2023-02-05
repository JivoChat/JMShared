//  
//  _JVArchiveHitItem+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension _JVArchiveHitItem {
    public var agents: [_JVAgent] {
        return _agents.jv_toArray()
    }
    
    public var chat: _JVChat? {
        return _chat
    }
    
    public var duration: TimeInterval {
        return TimeInterval(_duration)
    }
}
