//
//  JVMappable.swift
//  JivoShared
//
//  Created by Anton Karpushko on 05.03.2021.
//

import Foundation

public protocol JVMappable {
    func map<T>(_ transformingBlock: (Self) -> T) -> T
}

public extension JVMappable {
    func map<T>(_ transformingBlock: (Self) -> T) -> T {
        return transformingBlock(self)
    }
}
