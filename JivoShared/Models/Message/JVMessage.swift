//
//  JVMessage.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 11/05/2017.
//  Copyright Â© 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit
import JMRepicKit

open class JVMessage: JVBaseModel {
    @objc open dynamic var _ID: Int = 0
    @objc open dynamic var _localID: String = ""
    @objc open dynamic var _date: Date?
    @objc open dynamic var _orderingIndex: Int = 0
    @objc open dynamic var _clientID: Int = 0
    @objc open dynamic var _client: JVClient?
    @objc open dynamic var _chatID: Int = 0
    @objc open dynamic var _type: String = ""
    @objc open dynamic var _isMarkdown: Bool = false
    @objc open dynamic var _senderClient: JVClient?
    @objc open dynamic var _senderAgent: JVAgent?
    @objc open dynamic var _senderBot = Bool(false)
    @objc open dynamic var _status: String = ""
    @objc open dynamic var _reactions: Data?
    @objc open dynamic var _isIncoming: Bool = true
    @objc open dynamic var _sendingDate: TimeInterval = 0
    @objc open dynamic var _sendingFailed: Bool = false
    @objc open dynamic var _interactiveID: String?
    @objc open dynamic var _hasRead: Bool = false
    @objc open dynamic var _text: String = ""
    @objc open dynamic var _body: MessageBody?
    @objc open dynamic var _media: MessageMedia?
    @objc open dynamic var _iconLink: String?
    @objc open dynamic var _isOffline: Bool = false
    @objc open dynamic var _isHidden: Bool = false
    @objc open dynamic var _updatedAgent: JVAgent?
    @objc open dynamic var _updatedTimepoint: TimeInterval = 0
    @objc open dynamic var _isDeleted: Bool = false
    
    internal let localizer: Localizer
    
    public init(localizer: Localizer) {
        self.localizer = localizer
    }
    
    required public override init() {
        self.localizer = loc
    }
    
    open override class func primaryKey() -> String? {
        return nil
    }
    
    open override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    open override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
