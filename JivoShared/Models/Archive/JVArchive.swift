//  
//  JVArchive.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVArchive: JVBaseModel {
    @objc dynamic public var _ID: String = JVArchive.globalID()
    @objc dynamic public var _total: Int = 0
    @objc dynamic public var _archiveTotal: Int = 0
    @objc dynamic public var _latest: Double = 0
    @objc dynamic public var _lastID: String?
    @objc dynamic public var _isCleanedUp: Bool = false
    public let _hits = List<JVArchiveHit>()
    
    public class func globalID() -> String {
        return ":archive:"
    }
    
    public override class func primaryKey() -> String? {
        return "_ID"
    }
    
    public override func recursiveDelete(context: JVIDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
