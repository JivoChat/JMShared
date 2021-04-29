//
//  IntExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public extension Int {
    public var valuable: Int? {
        return (self == 0 ? nil : self)
    }

    public func hasBit(_ flag: Int) -> Bool {
        return ((self & flag) > 0)
    }

    public func toString() -> String {
        return "\(self)"
    }
}

extension Int: Mappable {}
