//
//  MessageSnippet+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension MessageSnippet {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? MessageSnippetGeneralChange {
            _URL = c.URL
            _title = c.title
            _iconURL = c.iconURL
        }
    }
}

public final class MessageSnippetGeneralChange: BaseModelChange {
    public let URL: String?
    public let title: String
    public let iconURL: String?
    public let HTML: String
    
    required public init( json: JsonElement) {
        URL = json["url"].valuable
        title = json["title"].stringValue
        iconURL = json["icon"].valuable
        HTML = json["html"].stringValue
        super.init(json: json)
    }
}
