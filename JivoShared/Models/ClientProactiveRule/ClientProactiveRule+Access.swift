//
//  ClientProactiveRule+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension ClientProactiveRule {    public var agent: Agent? {
        return _agent
    }
        public var date: Date {
        return _date!
    }
        public var text: String {
        return _text
    }
}
