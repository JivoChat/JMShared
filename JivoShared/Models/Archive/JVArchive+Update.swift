//  
//  JVArchive+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVArchive {
    public func performApply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVArchiveSliceChange {
            _total = c.total
            _archiveTotal = c.archiveTotal
            _latest = c.latest ?? _latest
            _lastID = c.lastID ?? _lastID
            
            let models = c.hits.filter(\.isValid)
            if c.fresh {
                let hits = context.upsert(of: JVArchiveHit.self, with: models)
                _hits.set(hits)
            }
            else {
                _hits.append(objectsIn: models.compactMap { model in
                    guard context.object(JVArchiveHit.self, primaryKey: model.ID) == nil else { return nil }
                    return context.upsert(of: JVArchiveHit.self, with: model)
                })
            }
            
            _isCleanedUp = false
        }
        else if let _ = change as? JVArchiveCleanupChange {
            _total = 0
            _latest = 0
            _lastID = nil
            _hits.removeAll()
            _isCleanedUp = true
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _hits.toArray(), recursive: true)
    }
}

public final class JVArchiveSliceChange: JVBaseModelChange {
    public let fresh: Bool
    public let status: Bool
    public let total: Int
    public let archiveTotal: Int
    public let latest: Double?
    public let lastID: String?
    public let hits: [JVArchiveHitGeneralChange]
    
    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: JVArchive.globalID())
    }
        public init(fresh: Bool,
         status: Bool,
         total: Int,
         archiveTotal: Int,
         latest: Double?,
         lastID: String?,
         hits: [JVArchiveHitGeneralChange]) {
        self.fresh = fresh
        self.status = status
        self.total = total
        self.archiveTotal = archiveTotal
        self.latest = latest
        self.lastID = lastID
        self.hits = hits
        
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
    
    public func copy(fresh: Bool) -> JVArchiveSliceChange {
        return JVArchiveSliceChange(
            fresh: fresh,
            status: status,
            total: total,
            archiveTotal: archiveTotal,
            latest: latest,
            lastID: lastID,
            hits: hits.map { $0.copyUnrelative() }
        )
    }
}

public final class JVArchiveCleanupChange: JVBaseModelChange {
    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: JVArchive.globalID())
    }
}
