//
//  JVMessageSnippet+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVMessageSnippet {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVMessageSnippetGeneralChange {
            _URL = c.URL
            _title = c.title
            _iconURL = c.iconURL
        }
    }
}

public final class JVMessageSnippetGeneralChange: JVBaseModelChange {
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
