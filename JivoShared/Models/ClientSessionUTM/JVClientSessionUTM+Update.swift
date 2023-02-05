//
//  _JVClientSessionUTM+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension _JVClientSessionUTM {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVClientSessionUTMGeneralChange {
            _source = c.source
            _keyword = c.keyword
            _campaign = c.campaign
            _medium = c.medium
            _content = c.content
        }
    }
}

public final class JVClientSessionUTMGeneralChange: JVBaseModelChange {
    public let source: String?
    public let keyword: String?
    public let campaign: String?
    public let medium: String?
    public let content: String?
    
    public override var isValid: Bool {
        let components = [source, keyword, campaign, medium, content]
        if components.contains(where: { $0.jv_hasValue }) {
            return true
        }
        else {
            return false
        }
    }
    
    required public init( json: JsonElement) {
        source = json["source"].valuable?.jv_unescape()
        keyword = json["keyword"].valuable?.jv_unescape()
        campaign = json["campaign"].valuable?.jv_unescape()
        medium = json["medium"].valuable?.jv_unescape()
        content = json["content"].valuable?.jv_unescape()
        super.init(json: json)
    }
}
