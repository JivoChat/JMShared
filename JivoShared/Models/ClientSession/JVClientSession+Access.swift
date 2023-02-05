//
//  _JVClientSession+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension _JVClientSession {
    public var creationDate: Date? {
        if _creationTS > 0 {
            return Date(timeIntervalSince1970: TimeInterval(_creationTS))
        }
        else if let firstPage = history.first {
            return firstPage.time
        }
        else {
            return nil
        }
    }
    
    public var UTM: _JVClientSessionUTM? {
        return _UTM
    }
    
    public var lastIP: String? {
        return _lastIP.jv_valuable
    }
    
    public var history: [_JVPage] {
        return _history.jv_toArray()
    }
    
    public var geo: _JVClientSessionGeo? {
        return _geo
    }
    
    public var chatStartPage: _JVPage? {
        return _chatStartPage ?? _currentPage ?? _history.last
    }
    
    public var currentPage: _JVPage? {
        return _currentPage
    }
}
