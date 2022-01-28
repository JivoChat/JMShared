//
//  JVClientSession+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVClientSession {    public var creationDate: Date? {
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
        public var UTM: JVClientSessionUTM? {
        return _UTM
    }
        public var lastIP: String? {
        return _lastIP.valuable
    }
        public var history: [JVPage] {
        return _history.toArray()
    }
        public var geo: ClientSessionGeo? {
        return _geo
    }
        public var chatStartPage: JVPage? {
        return _chatStartPage ?? _currentPage ?? _history.last
    }
        public var currentPage: JVPage? {
        return _currentPage
    }
}
