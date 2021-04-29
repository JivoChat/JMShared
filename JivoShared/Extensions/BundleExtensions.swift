//
//  BundleExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 14/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension Bundle {
//    func URLForDocument(named: String) -> URL? {
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls.first?.appendingPathComponent(named)
//    }
//
//    func URLForCache(named: String) -> URL? {
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
//        return urls.first?.appendingPathComponent(named)
//    }
        public var ID: String? {
        return infoDictionary?["CFBundleIdentifier"] as? String
    }
        public var name: String? {
        return (infoDictionary?["CFBundleDisplayName"] ?? infoDictionary?["CFBundleName"]) as? String
    }
        public var version: String {
        if let value = infoDictionary?["CFBundleShortVersionString"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
        public var build: String {
        if let value = infoDictionary?["CFBundleVersion"] as? String {
            return value
        }
        else {
            return "0"
        }
    }
        public var versionWithBuild: String {
        return "\(version) (\(build))"
    }
}
