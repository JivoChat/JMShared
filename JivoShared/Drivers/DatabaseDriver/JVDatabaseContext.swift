//
//  JVDatabaseContext.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JMTimelineKit

fileprivate var exceptionHandler: (Error) -> Void = { _ in }
public func JVDatabaseContextSetExceptionHandler(_ handler: @escaping (Error) -> Void) { exceptionHandler = handler }

public struct JVDatabaseContextMainKey<VT> {
    public let key: String
    public let value: VT
    
    public init(key: String, value: VT) {
        self.key = key
        self.value = value
    }
}
