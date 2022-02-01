//
//  JVClientSession.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVClientSession: JVBaseModel {
    @objc dynamic public var _creationTS: TimeInterval = 0
    @objc dynamic public var _UTM: JVClientSessionUTM?
    @objc dynamic public var _lastIP: String = ""
    @objc dynamic public var _geo: JVClientSessionGeo?
    @objc dynamic public var _chatStartPage: JVPage?
    @objc dynamic public var _currentPage: JVPage?
    public let _history = List<JVPage>()

    public override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
