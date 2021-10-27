//  
//  MediaUpload+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

public enum UploadingPurpose: Equatable {
    case transfer(Sender, chatID: Int)
    case avatar
    
    public var chatID: Int? {
        switch self {
        case .transfer(_, let chatID): return chatID
        case .avatar: return nil
        }
    }
}

public enum UploadingResult {
    public struct Success {
        public let storage: String
        public let mime: String
        public let name: String
        public let key: String
        public let link: String
        public let dataSize: Int
        public let pixelSize: CGSize
        
        public init(
            storage: String,
            mime: String,
            name: String,
            key: String,
            link: String,
            dataSize: Int,
            pixelSize: CGSize
        ) {
            self.storage = storage
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
            _chatID = c.chatID ?? 0
            _recipientType = c.recipientType
            _recipientID = c.recipientID
        }
    }
}

public final class MediaUploadChange: BaseModelChange {
    public let ID: String
    public let chatID: Int?
    public let filePath: String?
    public let purpose: UploadingPurpose
    public let width: Int
    public let height: Int
    public let sessionID: String
    public let completion: (UploadingResult) -> Void
    public init(ID: String,
                chatID: Int?,
                filePath: String?,
                purpose: UploadingPurpose,
                width: Int,
                height: Int,
                sessionID: String,
                completion: @escaping (UploadingResult) -> Void) {
        self.ID = ID
        self.chatID = chatID
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
            chatID: chatID,
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
        case .transfer(let target, _): return target.type.rawValue
        }
    }
    
    fileprivate var recipientID: Int {
        switch purpose {
        case .avatar: return 0
        case .transfer(let target, _): return target.ID
        }
    }
}
