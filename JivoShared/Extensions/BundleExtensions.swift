//
//  BundleExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 14/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension Bundle {
    static var jv_shared: Bundle {
        return Bundle(for: JMShared.self)
    }
    
    var jv_ID: String? {
        return infoDictionary?["CFBundleIdentifier"] as? String
    }
    
    var jv_name: String? {
        return (infoDictionary?["CFBundleDisplayName"] ?? infoDictionary?["CFBundleName"]) as? String
    }
    
    var jv_version: String {
        if let value = infoDictionary?["CFBundleShortVersionString"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
    
    var jv_build: String {
        if let value = infoDictionary?["CFBundleVersion"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
    
    var jv_versionWithBuild: String {
        return "\(jv_version) (\(jv_build))"
    }
}
