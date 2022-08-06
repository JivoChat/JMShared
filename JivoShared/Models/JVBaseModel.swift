//
//  JVBaseModel.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMRepicKit

open class JVBaseModel: Object {
    
    @objc dynamic public var _UUID: String = Foundation.UUID().uuidString.lowercased()
    
    required public override init() {
        super.init()
    }
    
    open func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
    }
    
    open func simpleDelete(context: IDatabaseContext) {
        _ = context.simpleRemove(objects: [self])
    }

    open func recursiveDelete(context: IDatabaseContext) {
        simpleDelete(context: context)
    }
}

open class BaseModelChange: NSObject {
    
    public let isOK: Bool
    
    override public init() {
        isOK = true

        super.init()
    }
    
    required public init(json: JsonElement) {
        isOK = json["ok"].boolValue
    }
    
    open var targetType: JVBaseModel.Type {
        abort()
    }
    
    open var isValid: Bool {
        return true
    }
    
    open var primaryValue: Int {
        abort()
    }
    
    open var integerKey: DatabaseContextMainKey<Int>? {
        return nil
    }
    
    open var stringKey: DatabaseContextMainKey<String>? {
        return nil
    }
}

public func validChange<T: BaseModelChange>(_ change: T?) -> T? {
    if let change = change, change.isValid {
        return change
    }
    else {
        return nil
    }
}

public enum SenderType: String {
    case `self`
    case client = "client"
    case agent = "agent"
    case bot = "bot"
    case guest = "visitor"
    case teamchat = "teamchat"
    case department = "department"
}

public struct Sender: Equatable {
    public let type: SenderType
    public let ID: Int
    
    public init(type: SenderType, ID: Int) {
        self.type = type
        self.ID = ID
    }
}

public struct MetaProviders {
    public let clientProvider: (Int) -> JVClient?
}

public protocol Presentable: Validatable {
    var senderType: SenderType { get }
    func metaImage(providers: MetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem?
}
public enum DisplayNameKind {
    case original
    case short
    case decorative
    case relative
}

public protocol Displayable: Presentable {
    var channel: JVChannel? { get }
    func displayName(kind: DisplayNameKind) -> String
    var integration: ChannelJoint? { get }
    var hashedID: String { get }
    var isMe: Bool { get }
    var isAvailable: Bool { get }
}
