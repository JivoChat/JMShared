//  
//  MediaUpload+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

public enum UploadingPurpose: Equatable {
    case transfer(Sender)
    case avatar
}

public enum UploadingResult {
    public struct Success {
        public let mime: String
        public let name: String
        public let key: String
        public let link: String
        public let dataSize: Int
        public let pixelSize: CGSize
        
        public init(
            mime: String,
            name: String,
            key: String,
            link: String,
            dataSize: Int,
            pixelSize: CGSize
        ) {
            self.mime = mime
            self.name = name
            self.key = key
            self.link = link
            self.dataSize = dataSize
            self.pixelSize = pixelSize
        }
    }
    
    case success(Success)
    case cannotExtractData
    case sizeLimitExceeded
    case exportingFailed
    case unknownError
}

extension MediaUpload {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? MediaUploadChange {
            if _ID == "" { _ID = c.ID }
            _filePath = c.filePath ?? String()
            _recipientType = c.recipientType
            _recipientID = c.recipientID
        }
    }
}

public final class MediaUploadChange: BaseModelChange {
    public let ID: String
    public let filePath: String?
    public let purpose: UploadingPurpose
    public let width: Int
    public let height: Int
    public let sessionID: String
    public let completion: (UploadingResult) -> Void
        public init(ID: String,
         filePath: String?,
         purpose: UploadingPurpose,
         width: Int,
         height: Int,
         sessionID: String,
         completion: @escaping (UploadingResult) -> Void) {
        self.ID = ID
        self.filePath = filePath
        self.purpose = purpose
        self.width = width
        self.height = height
        self.sessionID = sessionID
        self.completion = completion
        super.init()
    }

    required public init( json: JsonElement) {
        abort()
    }
    
    public func copy(filePath: String?) -> MediaUploadChange {
        return MediaUploadChange(
            ID: ID,
            filePath: filePath,
            purpose: purpose,
            width: width,
            height: height,
            sessionID: sessionID,
            completion: completion)
    }
    
    fileprivate var recipientType: String {
        switch purpose {
        case .avatar: return "self"
        case .transfer(let target): return target.type.rawValue
        }
    }
    
    fileprivate var recipientID: Int {
        switch purpose {
        case .avatar: return 0
        case .transfer(let target): return target.ID
        }
    }
}
