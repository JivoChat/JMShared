//
//  JVModelRef.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30.10.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public struct JVModelRefBehavior: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let strong = JVModelRefBehavior(rawValue: 1 << 0)
}
