//  
//  Timezone+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension Timezone {    public var ID: Int {
        return _ID
    }
        public var identifier: String {
        return _identifier ?? String()
    }
        public var GMT: String {
        return _displayGMT ?? String()
    }
    
    public func displayName(lang: LocaleLang) -> String {
        switch lang {
        case .ru: return _displayNameRu ?? _identifier ?? String()
        default: return _displayNameEn ?? _identifier ?? String()
        }
    }
        public var sortingOffset: Int {
        return _sortingOffset
    }
    
    public func sortingRegion(lang: LocaleLang) -> String {
        switch lang {
        case .ru: return _sortingRegionRu ?? _identifier ?? String()
        default: return _sortingRegionEn ?? _identifier ?? String()
        }
    }
}
