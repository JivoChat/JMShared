//
//  ObjectExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 11/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Validatable {
    var isValid: Bool { get }
}

extension Object: Validatable {
    public var isValid: Bool {
        return !isInvalidated
    }
    
    public func ifValid<T>() -> T? {
        return isValid ? self as? T : nil
    }
}
public func validate<T: Validatable>(_ object: T?) -> T? {
    guard let object = object else { return nil }
    return object.isValid ? object : nil
}
