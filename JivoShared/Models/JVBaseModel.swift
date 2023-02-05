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
    
    open func apply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
    }
    
    open func simpleDelete(context: JVIDatabaseContext) {
        _ = context.simpleRemove(objects: [self])
    }

    open func recursiveDelete(context: JVIDatabaseContext) {
        simpleDelete(context: context)
    }
}

open class JVBaseModelChange: NSObject {
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
    
    open var integerKey: JVDatabaseContextMainKey<Int>? {
        return nil
    }
    
    open var stringKey: JVDatabaseContextMainKey<String>? {
        return nil
    }
}

public func JVValidChange<T: JVBaseModelChange>(_ change: T?) -> T? {
    if let change = change, change.isValid {
        return change
    }
    else {
        return nil
    }
}

public enum JVSenderType: String {
    case `self`
    case client = "client"
    case agent = "agent"
    case bot = "bot"
    case guest = "visitor"
    case teamchat = "teamchat"
    case department = "department"
}

public struct JVSender: Equatable {
    public let type: JVSenderType
    public let ID: Int
    
    public init(type: JVSenderType, ID: Int) {
        self.type = type
        self.ID = ID
    }
}

public struct JVMetaProviders {
    public let clientProvider: (Int) -> _JVClient?
}

public protocol _JVPresentable: JVValidatable {
    var senderType: JVSenderType { get }
    func metaImage(providers: JVMetaProviders?, transparent: Bool, scale: CGFloat?) -> JMRepicItem?
}

public enum JVDisplayNameKind {
    case original
    case short
    case decorative(Decor)
    case relative
}

public extension JVDisplayNameKind {
    public struct Decor: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let role = Self(rawValue: 1 << 0)
        public static let richStatus = Self(rawValue: 1 << 1)
        public static let all = Self(rawValue: ~0)
    }
}

public protocol _JVDisplayable: _JVPresentable {
    var channel: _JVChannel? { get }
    func displayName(kind: JVDisplayNameKind) -> String
    var integration: JVChannelJoint? { get }
    var hashedID: String { get }
    var isMe: Bool { get }
    var isAvailable: Bool { get }
}
