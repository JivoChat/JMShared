//
//  UILabelExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 16/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMShared
import UIKit

extension UILabel {
    public var hasText: Bool {
        if let text = text {
            return !text.isEmpty
        }
        else {
            return false
        }
    }
    
    public func calculateSize(for width: CGFloat) -> CGSize {
        if hasText {
            let bounds = CGRect(x: 0, y: 0, width: width, height: .infinity)
            return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
        }
        else {
            return CGSize(width: font.xHeight, height: font.lineHeight)
        }
    }
    
    public func calculateHeight(for width: CGFloat) -> CGFloat {
        return calculateSize(for: width).height
    }
}
