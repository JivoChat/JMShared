//
//  ArrayExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 28/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JivoShared

public extension Array {
    public var hasElements: Bool {
        return !isEmpty
    }
    
    public var hasOneElement: Bool {
        return (count == 1)
    }
}

public extension Sequence where Iterator.Element: OptionalType {
    public func flatten() -> [Iterator.Element.Wrapped] {
        return compactMap { $0.optional }
    }
}

public extension Array where Element: BaseModel {
    public func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        forEach { $0.apply(inside: context, with: change) }
    }
}

public extension Array where Element == String {
    public func stringOrEmpty(at index: Int) -> String {
        return (index < count ? self[index] : String())
    }
    
    public func markupMasked(_ isMasked: Bool) -> [Element] {
        if isMasked {
            return self
        }
        else {
            return map { $0
                .replacingOccurrences(of: "<mask>", with: "")
                .replacingOccurrences(of: "</mask>", with: "")
            }
        }
    }
}

public extension Array where Element: Equatable {
    public func unique() -> [Element] {
        var uniqueValues = [Element]()
        
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        
        return uniqueValues
    }
    
    public func doesNotContain(_ element: Element) -> Bool {
        return !contains(element)
    }
    
    mutating func toggle(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
        else {
            append(element)
        }
    }
}

public extension Array where Element == Int {
    public func stringify() -> [String] {
        return map { String("\($0)") }
    }
}
public func <<= <Element> (lhs: inout Array<Element>, rhs: Element) {
    lhs.append(rhs)
}
