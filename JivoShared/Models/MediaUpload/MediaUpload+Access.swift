//  
//  MediaUpload+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension MediaUpload {
    public var ID: String {
        return _ID
    }
    
    public var fileURL: URL? {
        return URL(string: _filePath)
    }

    public var purpose: UploadingPurpose? {
        switch _recipientType {
        case "self":
            return .avatar
            
        default:
            guard let type = SenderType(rawValue: _recipientType) else { return nil }
            let target = Sender(type: type, ID: _recipientID)
            return .transfer(target, chatID: _chatID)
        }
    }
}
