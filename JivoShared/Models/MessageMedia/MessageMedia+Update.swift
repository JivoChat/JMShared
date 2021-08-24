//
//  MessageMedia+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension MessageMedia {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? MessageMediaGeneralChange {
            _type = c.type
            _mime = c.mime ?? ""
            _thumbLink = c.thumbLink ?? ""
            _fullLink = c.fullLink
            _emoji = c.emoji ?? ""
            _size = c.size
            _width = c.width
            _height = c.height
            _duration = c.duration
            _latitude = c.latitude ?? 0
            _longitude = c.longitude ?? 0
            _phone = c.phone ?? ""
            _title = c.title
            _link = c.link
            _text = c.text

            let name = (c.title.valuable ?? c.name).trimmedZeros()
            if let performer = c.performer?.trimmedZeros() {
                _name = "\(performer) - \(name)"
            }
            else {
                _name = name
            }
        }
    }
}

public final class MessageMediaGeneralChange: BaseModelChange {
    public let type: String
    public let mime: String?
    public let thumbLink: String?
    public let fullLink: String
    public let emoji: String?
    public let name: String
    public let title: String
    public let performer: String?
    public let size: Int
    public let width: Int
    public let height: Int
    public let duration: Int
    public let latitude: Double?
    public let longitude: Double?
    public let phone: String?
    public let link: String?
    public let text: String?

    public override var isValid: Bool {
        guard type != "error" else { return false }
        return true
    }
        public init(type: String, mime: String, name: String, link: String, size: Int, width: Int, height: Int) {
        self.type = type
        self.mime = mime
        self.thumbLink = nil
        self.fullLink = link
        self.emoji = nil
        self.name = name
        self.title = self.name
        self.performer = nil
        self.size = size
        self.width = width
        self.height = height
        self.duration = 0
        self.latitude = nil
        self.longitude = nil
        self.phone = nil
        self.link = nil
        self.text = nil
        super.init()
    }
    
    required public init( json: JsonElement) {
        type = json["type"].stringValue
        mime = nil
        thumbLink = json["thumb"].stringValue
        fullLink = json["file"].stringValue
        emoji = json["emoji"].string
        name = json["file_name"].string?.valuable ?? json["name"].stringValue
        title = json["title"].stringValue
        performer = json["performer"].string
        size = json["file_size"].intValue
        width = json["width"].intValue
        height = json["height"].intValue
        duration = json["duration"].intValue
        latitude = json["latitude"].double ?? json["latitude"].string?.toDouble()
        longitude = json["longitude"].double ?? json["longitude"].string?.toDouble()
        phone = json["phone"].string
        link = json["url"].string
        text = json["text"].string
        super.init(json: json)
    }
}
