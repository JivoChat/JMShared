//
//  _JVMessageImage+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension _JVMessageImage {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVMessageImageGeneralChange {
            _fileName = c.fileName
            _URL = c.URL
            _uploadTS = c.uploadTS
        }
    }
}

public final class JVMessageImageGeneralChange: JVBaseModelChange {
    public let fileName: String
    public let URL: String
    public let uploadTS: Int
    
    required public init( json: JsonElement) {
        fileName = json["filename"].stringValue
        URL = json["url"].stringValue
        uploadTS = json["uploaded_ts"].intValue
        super.init(json: json)
    }
}
