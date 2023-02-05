//
//  _JVClientSession.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class _JVClientSession: JVBaseModel {
    @objc dynamic public var _creationTS: TimeInterval = 0
    @objc dynamic public var _UTM: _JVClientSessionUTM?
    @objc dynamic public var _lastIP: String = ""
    @objc dynamic public var _geo: _JVClientSessionGeo?
    @objc dynamic public var _chatStartPage: _JVPage?
    @objc dynamic public var _currentPage: _JVPage?
    public let _history = List<_JVPage>()

    public override func recursiveDelete(context: JVIDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
