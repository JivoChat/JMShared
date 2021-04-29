//
//  BoolExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 28/08/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension Bool {
    public func inverted() -> Bool {
        return !self
    }
}

extension Bool: Mappable {}
