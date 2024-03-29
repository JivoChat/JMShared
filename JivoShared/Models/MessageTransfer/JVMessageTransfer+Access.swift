//
//  JVMessageTransfer+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVMessageTransfer {
    public var agentID: Int {
        return _agentID
    }
    
    public var comment: String? {
        return _comment
    }
}
