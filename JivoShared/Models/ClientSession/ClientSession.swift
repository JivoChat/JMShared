//
//  ClientSession.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class ClientSession: JVBaseModel {
    @objc dynamic public var _creationTS: TimeInterval = 0
    @objc dynamic public var _UTM: ClientSessionUTM?
    @objc dynamic public var _lastIP: String = ""
    @objc dynamic public var _geo: ClientSessionGeo?
    @objc dynamic public var _chatStartPage: Page?
    @objc dynamic public var _currentPage: Page?
    public let _history = List<Page>()

    public override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
