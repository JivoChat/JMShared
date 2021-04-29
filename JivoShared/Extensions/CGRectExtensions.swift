//
//  CGRectExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 17/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public extension CGRect {
    public func reduceBy(insets: UIEdgeInsets) -> CGRect {
        return CGRect(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: width - insets.left - insets.right,
            height: height - insets.top - insets.bottom
        )
    }
    
    public func containerSize() -> CGSize {
        return CGSize(width: width, height: .infinity)
    }
    
    public func divide(by axis: NSLayoutConstraint.Axis) -> (slice: CGRect, remainder: CGRect) {
        switch axis {
        case .horizontal: return divided(atDistance: height * 0.5, from: .minYEdge)
        case .vertical: return divided(atDistance: width * 0.5, from: .minXEdge)
        @unknown default: return divided(atDistance: height * 0.5, from: .minYEdge)
        }
    }
    
    public func divide(by axis: NSLayoutConstraint.Axis, number: Int) -> [CGRect] {
        switch axis {
        case .horizontal:
            let base = divided(atDistance: height / CGFloat(number), from: .minYEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: 0, dy: base.height * CGFloat(index))
            }
            
        case .vertical:
            let base = divided(atDistance: width / CGFloat(number), from: .minXEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: base.width * CGFloat(index), dy: 0)
            }
            
        @unknown default:
            let base = divided(atDistance: height / CGFloat(number), from: .minYEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: 0, dy: base.height * CGFloat(index))
            }
        }
    }
    
    public func divide(percent: CGFloat, from edge: CGRectEdge) -> (slice: CGRect, remainder: CGRect) {
        let distance: CGFloat
        switch edge {
        case .minXEdge, .maxXEdge: distance = width * percent
        case .minYEdge, .maxYEdge: distance = height * percent
        }
        
        return divided(atDistance: distance, from: edge)
    }
    
    public func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    public func bounds() -> CGRect {
        return CGRect(origin: .zero, size: size)
    }
}
