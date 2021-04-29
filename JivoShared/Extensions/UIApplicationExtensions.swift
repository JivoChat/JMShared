//
//  UIApplicationExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/09/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    public var isActive: Bool {
        switch applicationState {
        case .active: return true
        case .inactive: return false
        case .background: return false
        @unknown default: return false
        }
    }
    
    public func openLocalizedURL(for key: String) {
        let link = loc[key]
        guard let url = URL(string: link) else { return }
        open(url, options: [:], completionHandler: nil)
    }
    
    public func discardCachedLaunchScreen() {
        let path = NSHomeDirectory() + "/Library/SplashBoard"
        try? FileManager.default.removeItem(atPath: path)
    }
}

public extension UIApplication.State {
    public var description: String {
        switch self {
        case .active: return "active"
        case .background: return "background"
        case .inactive: return "inactive"
        @unknown default: return String(describing: self)
        }
    }
}
