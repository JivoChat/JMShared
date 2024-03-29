//  
//  JVPage+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVPage {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVPageGeneralChange {
            _URL = c.URL
            _title = c.title
            _time = c.time
        }
    }
}

public final class JVPageGeneralChange: JVBaseModelChange {
    public let URL: String
    public let title: String
    public let time: String?
    
    public override var isValid: Bool {
        if URL.isEmpty {
            return false
        }
        else if let _ = NSURL(string: URL) {
            return true
        }
        else {
            return false
        }
    }
    
    required public init( json: JsonElement) {
        URL = json["url"].stringValue
        title = json["title"].stringValue
        time = json["time"].string
        super.init(json: json)
    }
}
