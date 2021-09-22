//
//  ClientCustomData+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension ClientCustomData {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientCustomDataGeneralChange {
            _title = c.title
            _key = c.key
            _content = c.content
            _link = c.link
        }
    }
}

public final class ClientCustomDataGeneralChange: BaseModelChange {
    public let title: String?
    public let key: String?
    public let content: String
    public let link: String?
    
    required public init( json: JsonElement) {
        title = json["title"].string?.valuable
        key = json["key"].string?.valuable
        content = json["content"].stringValue
        link = json["link"].string?.valuable
        super.init(json: json)
    }
}
