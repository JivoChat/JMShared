//
//  MessageTransfer.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class MessageTransfer: JVBaseModel {
    @objc dynamic public var _agentID: Int = 0
    @objc dynamic public var _comment: String?
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        
    }
}
