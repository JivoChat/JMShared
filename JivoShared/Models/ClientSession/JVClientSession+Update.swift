//
//  JVClientSession+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVClientSession {
    public func performApply(inside context: IDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVClientSessionGeneralChange {
            _creationTS = c.creationTS ?? _creationTS
            _lastIP = c.lastIP
            
            _history.set(context.insert(of: JVPage.self, with: c.history))

            if let value = c.UTM {
                _UTM = context.insert(of: JVClientSessionUTM.self, with: value)
            }
            
            if let value = c.geo {
                _geo = context.insert(of: JVClientSessionGeo.self, with: value)
            }
            
            if let value = c.chatStartPage {
                _chatStartPage = context.insert(of: JVPage.self, with: value)
            }
            
            if let value = c.currentPage {
                _currentPage = context.insert(of: JVPage.self, with: value)
            }
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _history.toArray(), recursive: true)
        context.customRemove(objects: [_UTM, _geo, _chatStartPage, _currentPage].flatten(), recursive: true)
    }
}

public final class JVClientSessionGeneralChange: JVBaseModelChange {
    public let creationTS: TimeInterval?
    public let UTM: JVClientSessionUTMGeneralChange?
    public let lastIP: String
    public let history: [JVPageGeneralChange]?
    public let geo: JVClientSessionGeoGeneralChange?
    public let chatStartPage: JVPageGeneralChange?
    public let currentPage: JVPageGeneralChange?
    
    required public init( json: JsonElement) {
        if let value = json.has(key: "created_ts") {
            creationTS = value.doubleValue
        }
        else if let _ = json.has(key: "created_datetime") {
            creationTS = nil
            
//            if let date = value.string?.parseDateUsingFullFormat() {
//                creationTS = Int(date.timeIntervalSince1970)
//            }
//            else {
//                creationTS = nil
//            }
        }
        else {
            creationTS = nil
        }
        
        UTM = (json.has(key: "utm") ?? json).parse()
        lastIP = json["ip"].stringValue
        history = json["prechat_navigates"].parseList()
        geo = json.has(key: "geoip")?.parse() ?? json.has(key: "social")?.parse() ?? nil
        chatStartPage = json["chat_start_page"].parse()
        currentPage = json["current_page"].parse()
        super.init(json: json)
    }
}
