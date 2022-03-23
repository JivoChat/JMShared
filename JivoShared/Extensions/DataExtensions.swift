//
//  DataExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 14/06/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import SwiftyNSException

public extension Data {
    static func with(string: String, encoding: String.Encoding) -> Data? {
        return string.data(using: encoding)
    }
    
    func toHex() -> String {
        return map({ String(format: "%02x", $0) }).joined()
    }
    
    func unarchive<T: NSCoding>(type: T.Type) -> T? {
        let contents = self
        return try? handle({ NSKeyedUnarchiver.unarchiveObject(with: contents) as? T })
    }
}
