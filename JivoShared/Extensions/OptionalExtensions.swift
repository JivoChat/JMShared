//
//  OptionalExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift

public protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

public extension Optional {
    var hasValue: Bool {
        if let _ = self {
            return true
        }
        else {
            return false
        }
    }
}

extension Optional: OptionalType {
    public var optional: Wrapped? {
        return self
    }

    mutating func readAndReset() -> Wrapped? {
        defer { self = nil }
        return self
    }
}

public extension Optional where Wrapped: Object {
    func ifValid() -> Wrapped? {
        return self?.ifValid()
    }
}
