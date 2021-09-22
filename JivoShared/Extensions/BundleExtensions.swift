//
//  BundleExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 14/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension Bundle {
    var ID: String? {
        return infoDictionary?["CFBundleIdentifier"] as? String
    }
    
    var name: String? {
        return (infoDictionary?["CFBundleDisplayName"] ?? infoDictionary?["CFBundleName"]) as? String
    }
    
    var version: String {
        if let value = infoDictionary?["CFBundleShortVersionString"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
    
    var build: String {
        if let value = infoDictionary?["CFBundleVersion"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
    
    var versionWithBuild: String {
        return "\(version) (\(build))"
    }
}

public extension Bundle {
    static var jmShared: Bundle {
        return Bundle(for: JMShared.self)
    }
}
