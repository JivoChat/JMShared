//
//  JVMessageMedia+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
public enum MessageMediaType {
    case photo
    case sticker
    case document
    case audio
    case voice
    case video
    case comment
    case location
    case contact
    case conference
    case story
    case unknown
}
public enum MessageMediaSizingMode {
    case original
    case cropped
}

extension JVMessageMedia {
    public var type: MessageMediaType {
        switch _type {
        case "photo": return .photo
        case "sticker": return .sticker
        case "document": return .document
        case "audio": return .audio
        case "voice": return .voice
        case "video": return .video
        case "comment": return .comment
        case "location": return .location
        case "contact": return .contact
        case "conference": return .conference
        case "story": return .story
        default: return .unknown
        }
    }
    
    public var mime: String {
        return _mime
    }
    
    public var thumbURL: URL? {
        if _thumbLink.isEmpty {
            return nil
        }
        else if let url = NSURL(string: _thumbLink) {
            return url as URL
        }
        else {
            return nil
        }
    }
    
    public var fullURL: URL? {
        if _fullLink.isEmpty {
            return nil
        }
        else if let url = NSURL(string: _fullLink) {
            return url as URL
        }
        else {
            return nil
        }
    }
    
    public var emoji: String? {
        return _emoji.valuable
    }
    
    public var name: String? {
        return _name.valuable
    }
    
    public var dataSize: Int {
        return _size
    }
    
    public var duration: TimeInterval {
        return TimeInterval(_duration)
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        if _latitude == 0, _longitude == 0 {
            return nil
        }
        else {
            return CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
        }
    }
    
    public var conference: MessageBodyConference? {
        guard type == .conference else {
            return nil
        }
        
        if let link = _link, not(link.isEmpty) {
            let url = URL(string: link)
            return MessageBodyConference(url: url, title: _title ?? String())
        }
        else {
            return MessageBodyConference(url: nil, title: _title ?? String())
        }
    }
    
    public var story: MessageBodyStory? {
        guard type == .story else {
            return nil
        }
        
        return MessageBodyStory(
            text: _text ?? String(),
            fileName: _name,
            thumb: thumbURL,
            file: fullURL,
            title: _title ?? String()
        )
    }
    
    public var phone: String? {
        return _phone.valuable
    }
    
    public var text: String? {
        return _text?.valuable
    }
    
    public var originalSize: CGSize {
        let width = CGFloat(_width)
        let height = CGFloat(_height)
        return CGSize(width: width, height: height)
    }
    
    public func pixelSize(minimum: CGFloat = 0, maximum: CGFloat = 0) -> (CGSize, MessageMediaSizingMode) {
        let width = CGFloat(_width) / UIScreen.main.scale
        let height = CGFloat(_height) / UIScreen.main.scale
        let minimalSide = min(width, height)
        
        if minimalSide == 0 {
            return (.zero, .original)
        }
        else if minimum > 0, minimalSide < minimum {
            let size = CGSize(width: minimum, height: minimum)
            return (size, .cropped)
        }
        else if maximum > 0, minimalSide > maximum {
            let size = CGSize(width: maximum, height: maximum)
            return (size, .cropped)
        }
        else {
            let size = CGSize(width: minimalSide, height: minimalSide)
            return (size, .cropped)
        }
    }
}
