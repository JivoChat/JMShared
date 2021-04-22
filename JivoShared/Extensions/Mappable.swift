//
//  Mappable.swift
//  JivoShared
//
//  Created by macbook on 05.03.2021.
//

import Foundation

public protocol Mappable {
    func map<T>(_ transformingBlock: (Self) -> T) -> T
}

public extension Mappable {
    func map<T>(_ transformingBlock: (Self) -> T) -> T {
        return transformingBlock(self)
    }
}
