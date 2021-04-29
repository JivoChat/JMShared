//
//  DatabaseOptions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public typealias DatabaseSubscriberToken = UUID

public struct DatabaseResponseSort {
    public let keyPath: String
    public let ascending: Bool
    
    public init(keyPath: String, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
}

public struct DatabaseRequestOptions {
    public let filter: NSPredicate?
    public let sortBy: [DatabaseResponseSort]
    public let notificationName: Notification.Name?
    
    public init(filter: NSPredicate? = nil, sortBy: [DatabaseResponseSort] = [], notificationName: Notification.Name? = nil) {
        self.filter = filter
        self.sortBy = sortBy
        self.notificationName = notificationName
    }
}
