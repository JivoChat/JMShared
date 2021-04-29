//
//  ModelRef.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30.10.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift

public enum ModelRefBehavior {
    case threading
    case storage
}

public final class ModelRef<Value: BaseModel> {
    private weak var databaseDriver: IDatabaseDriver?
    
    private let uuid: String?
    private var reference: ThreadSafeReference<Value>?
    
    public init(databaseDriver: IDatabaseDriver, value: Value?, behavior: ModelRefBehavior) {
        self.databaseDriver = databaseDriver
        
        if let value = value {
            switch behavior {
            case .threading:
                reference = ThreadSafeReference(to: value)
                uuid = nil
            case .storage:
                reference = nil
                uuid = value._UUID
            }
        }
        else {
            reference = nil
            uuid = nil
        }
    }
    
    public var resolved: Value? {
        return resolve()
    }
    
    public func resolve() -> Value? {
        if let ref = reference {
            reference = nil
            
            guard let object = databaseDriver?.resolve(ref: ref), object.isValid else { return nil }
            reference = ThreadSafeReference(to: object)
            
            return object
        }
        else if let uuid = uuid {
            let mainKey = DatabaseContextMainKey(key: "_UUID", value: uuid)
            return databaseDriver?.object(Value.self, mainKey: mainKey)
        }
        else {
            return nil
        }
    }
}
