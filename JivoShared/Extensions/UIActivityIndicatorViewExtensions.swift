//
//  UIActivityIndicatorViewExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.10.2019.
//  Copyright © 2019 JivoSite. All rights reserved.
//

import Foundation
import JivoShared
import UIKit

extension UIActivityIndicatorView {
    public func started() -> UIActivityIndicatorView {
        startAnimating()
        return self
    }
}

extension UIActivityIndicatorView.Style {
    public static var auto: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        }
        else {
            return .gray
        }
    }
}
