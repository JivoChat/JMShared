//
//  IntExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public extension Int {
    var valuable: Int? {
        return (self == 0 ? nil : self)
    }

    func hasBit(_ flag: Int) -> Bool {
        return ((self & flag) > 0)
    }

    func toString() -> String {
        return "\(self)"
    }
}

extension Int: Mappable {}
