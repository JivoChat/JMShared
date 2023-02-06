//
//  _JVClient+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

public enum JVClientStatus {
    case none
    case alive
    case online
}

public enum JVClientTypingStatus {
    case active(input: String?)
    case inactive
}

public enum JVClientDetailsUpdateError: Error {
    case missing
    case invalid
    case tooLong
}

public struct _JVClientProfile {
    public let emailByClient: String?
    public let emailByAgent: String?
    public let phoneByClient: String?
    public let phoneByAgent: String?
    public let comment: String?
    public let countryName: String?
    public let cityName: String?
    
    public var hasEmail: Bool {
        if let _ = emailByClient { return true }
        if let _ = emailByAgent { return true }
        return false
    }
    
    public var primaryPhone: String? {
        return phoneByAgent ?? phoneByClient
    }
}
