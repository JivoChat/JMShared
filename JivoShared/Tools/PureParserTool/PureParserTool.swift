//
//  PureParserTool.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 01.12.2019.
//  Copyright © 2019 JivoSite. All rights reserved.
//

import Foundation
import PureParser

public protocol IPureParserTool: class {
    func assign(variable name: String, value: String?)
    func activate(alias: String, _ rule: Bool)
    func execute(_ formula: String, collapseSpaces: Bool) -> String
}
public final class PureParserTool: IPureParserTool {
    private let parser = PureParser()
    
    public init() {}
    
    public func assign(variable name: String, value: String?) {
        parser.assign(variable: name, value: value)
    }
    
    public func activate(alias: String, _ rule: Bool) {
        parser.activate(alias: alias, rule)
    }
    
    public func execute(_ formula: String, collapseSpaces: Bool) -> String {
        return parser.execute(formula, collapseSpaces: collapseSpaces, resetOnFinish: true)
    }
}
