//
//  ModelRef.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30.10.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift

public struct ModelRefBehavior: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let strong = ModelRefBehavior(rawValue: 1 << 0)
}

public final class ModelRef<Value: BaseModel> {
    private weak var databaseDriver: IDatabaseDriver?
    private let uuid: String?
    private let behavior: ModelRefBehavior
    
    public init(databaseDriver: IDatabaseDriver, value: Value?, behavior: ModelRefBehavior) {
        self.databaseDriver = databaseDriver
        self.uuid = value?._UUID
        self.behavior = behavior
    }
    
    public var resolved: Value? {
        return resolve()
    }
    
    public func resolve() -> Value? {
        guard let uuid = uuid else {
            return nil
        }
        
        let mainKey = DatabaseContextMainKey(key: "_UUID", value: uuid)
        if let object = databaseDriver?.object(Value.self, mainKey: mainKey) {
            return object
        }
        else if behavior.contains(.strong) {
            databaseDriver?.refresh()
            return databaseDriver?.object(Value.self, mainKey: mainKey)
        }
        else {
            return nil
        }
    }
}

