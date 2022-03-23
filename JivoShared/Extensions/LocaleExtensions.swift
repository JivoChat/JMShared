//
//  LocaleExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 21/06/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension Locale {
    var langID: String? {
        let parts = identifier.components(separatedBy: "_")
        return parts.first
    }
    
    var countryID: String? {
        let parts = identifier.components(separatedBy: "_")
        if parts.count > 1 {
            return parts.last
        }
        else {
            return nil
        }
    }
    
    var nativeTitle: String {
        if let name = (self as NSLocale).displayName(forKey: .languageCode, value: identifier) {
            return name.capitalized
        }
        else {
            return identifier
        }
    }
}
