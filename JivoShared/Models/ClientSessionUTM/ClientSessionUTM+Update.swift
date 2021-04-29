//
//  ClientSessionUTM+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension ClientSessionUTM {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientSessionUTMGeneralChange {
            _source = c.source
            _keyword = c.keyword
            _campaign = c.campaign
            _medium = c.medium
            _content = c.content
        }
    }
}

public final class ClientSessionUTMGeneralChange: BaseModelChange {
    public let source: String?
    public let keyword: String?
    public let campaign: String?
    public let medium: String?
    public let content: String?
    
    public override var isValid: Bool {
        let components = [source, keyword, campaign, medium, content]
        if components.contains(where: { $0.hasValue }) {
            return true
        }
        else {
            return false
        }
    }
    
    required public init( json: JsonElement) {
        source = json["source"].valuable?.unescape()
        keyword = json["keyword"].valuable?.unescape()
        campaign = json["campaign"].valuable?.unescape()
        medium = json["medium"].valuable?.unescape()
        content = json["content"].valuable?.unescape()
        super.init(json: json)
    }
}
