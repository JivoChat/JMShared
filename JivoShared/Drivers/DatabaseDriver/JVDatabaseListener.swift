//
//  JVDatabaseListener.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public final class JVDatabaseListener {
    private let token: JVDatabaseSubscriberToken
    private weak var databaseDriver: JVIDatabaseDriver!
        public init(token: JVDatabaseSubscriberToken, databaseDriver: JVIDatabaseDriver) {
        self.token = token
        self.databaseDriver = databaseDriver
    }
    
    deinit {
        databaseDriver?.unsubscribe(token)
    }
}
