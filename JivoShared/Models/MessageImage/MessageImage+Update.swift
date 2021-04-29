//
//  MessageImage+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

extension MessageImage {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? MessageImageGeneralChange {
            _fileName = c.fileName
            _URL = c.URL
            _uploadTS = c.uploadTS
        }
    }
}

public final class MessageImageGeneralChange: BaseModelChange {
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
