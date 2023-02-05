//
//  _JVClientCustomData+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension _JVClientCustomData {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVClientCustomDataGeneralChange {
            _title = c.title
            _key = c.key
            _content = c.content
            _link = c.link
        }
    }
}

public final class JVClientCustomDataGeneralChange: JVBaseModelChange {
    public let title: String?
    public let key: String?
    public let content: String
    public let link: String?
    
    required public init( json: JsonElement) {
        title = json["title"].string?.jv_valuable
        key = json["key"].string?.jv_valuable
        content = json["content"].stringValue
        link = json["link"].string?.jv_valuable
        super.init(json: json)
    }
}
