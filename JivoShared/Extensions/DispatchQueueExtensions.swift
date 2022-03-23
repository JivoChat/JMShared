//
//  DispatchQueueExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/06/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    static var onceExecutingLock = NSLock()
    static var onceExecutedTokens = Set<UUID>()

    class func globalOnce(token: UUID, block: () -> Void) {
        onceExecutingLock.lock()
        defer { onceExecutingLock.unlock() }

        guard !onceExecutedTokens.contains(token) else { return }
        onceExecutedTokens.insert(token)

        block()
    }

    func delayed(seconds: TimeInterval, block: @escaping () -> Void) {
        asyncAfter(
            deadline: .now() + seconds,
            execute: block
        )
    }

}
