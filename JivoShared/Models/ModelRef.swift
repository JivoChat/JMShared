//
//  ModelRef.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30.10.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift

public final class ModelRef<Value: Object> {
    private weak var databaseDriver: IDatabaseDriver?
    
    private var reference: ThreadSafeReference<Value>?
    
    public init(databaseDriver: IDatabaseDriver, value: Value) {
        self.databaseDriver = databaseDriver
        reference = ThreadSafeReference(to: value)
    }
    
    public var resolved: Value? {
        return resolve()
    }
    
    public func resolve() -> Value? {
        guard let ref = reference else { return nil }
        reference = nil
        
        guard let object = databaseDriver?.resolve(ref: ref), object.isValid else { return nil }
        reference = ThreadSafeReference(to: object)
        
        return object
    }
}
