//  
//  Archive+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension Archive {
    public var latest: Double? {
        return (_latest == 0 ? nil : _latest)
    }
    
    public var lastID: String? {
        return (_lastID == "" ? nil : _lastID)
    }
    
    public var total: Int {
        return _total
    }
    
    public var archiveTotal: Int {
        return _archiveTotal
    }
    
    public var hits: [ArchiveHit] {
        return Array(_hits)
    }
    
    public var isCleanedUp: Bool {
        return _isCleanedUp
    }
    
    public func sortedHits(by sort: ArchiveHitSort) -> [ArchiveHit] {
        switch sort {
        case .byTime:
            return Array(_hits.sorted(byKeyPath: "_latestActivityTime", ascending: false))
            
        case .byScore:
            return Array(_hits.sorted(byKeyPath: "_score", ascending: false))
        }
    }
}
