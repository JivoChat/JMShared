//
//  DispatchCallback.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 31.10.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public func DispatchCallback<Value>(_ block: ((Value) -> Void)?, async queue: DispatchQueue) -> ((Value) -> Void) {
    return { value in
        queue.async { block?(value) }
    }
}

public func DispatchCallback<Value>(_ block: ((Value) -> Void)?, sync queue: DispatchQueue) -> ((Value) -> Void) {
    return { value in
        queue.sync { block?(value) }
    }
}
