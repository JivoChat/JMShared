//  
//  Archive+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

extension Archive {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ArchiveSliceChange {
            _total = c.total
            _archiveTotal = c.archiveTotal
            _latest = c.latest ?? _latest
            _lastID = c.lastID ?? _lastID
            
            let models = c.hits.filter(\.isValid)
            if c.fresh {
                let hits = context.upsert(of: ArchiveHit.self, with: models)
                _hits.set(hits)
            }
            else {
                _hits.append(objectsIn: models.compactMap { model in
                    guard context.object(ArchiveHit.self, primaryKey: model.ID) == nil else { return nil }
                    return context.upsert(of: ArchiveHit.self, with: model)
                })
            }
            
            _isCleanedUp = false
        }
        else if let _ = change as? ArchiveCleanupChange {
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

public final class ArchiveSliceChange: BaseModelChange {
    public let fresh: Bool
    public let status: Bool
    public let total: Int
    public let archiveTotal: Int
    public let latest: Double?
    public let lastID: String?
    public let hits: [ArchiveHitGeneralChange]
    
    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: Archive.globalID())
    }
        public init(fresh: Bool,
         status: Bool,
         total: Int,
         archiveTotal: Int,
         latest: Double?,
         lastID: String?,
         hits: [ArchiveHitGeneralChange]) {
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
    
    public func copy(fresh: Bool) -> ArchiveSliceChange {
        return ArchiveSliceChange(
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

public final class ArchiveCleanupChange: BaseModelChange {
    public override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: Archive.globalID())
    }
}
