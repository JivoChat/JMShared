//  
//  JVArchiveHitItem+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVArchiveHitItem {    public var agents: [JVAgent] {
        return _agents.toArray()
    }
        public var chat: JVChat? {
        return _chat
    }
        public var duration: TimeInterval {
        return TimeInterval(_duration)
    }
}
