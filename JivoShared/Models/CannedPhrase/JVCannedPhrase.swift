//
//  CannedPhrase.swift
//  JMShared
//
//  Created by Yulia on 02.11.2022.
//

import Foundation

public final class JVCannedPhrase: JVBaseModel {
    @objc dynamic public var _sessionScore: Int = 0
    @objc dynamic public var _totalScore: Int = 0
    @objc dynamic public var _message: String = ""
    @objc dynamic public var _messageHashID: String = ""
    @objc dynamic public var _timestamp: Int = 0
    @objc dynamic public var _isDeleted: Bool = false
    @objc dynamic public var _uid: String = ""
    
    public override func apply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
