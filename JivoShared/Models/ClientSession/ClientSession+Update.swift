//
//  ClientSession+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension ClientSession {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientSessionGeneralChange {
            _creationTS = c.creationTS ?? _creationTS
            _lastIP = c.lastIP
            
            _history.set(context.insert(of: Page.self, with: c.history))

            if let value = c.UTM {
                _UTM = context.insert(of: ClientSessionUTM.self, with: value)
            }
            
            if let value = c.geo {
                _geo = context.insert(of: ClientSessionGeo.self, with: value)
            }
            
            if let value = c.chatStartPage {
                _chatStartPage = context.insert(of: Page.self, with: value)
            }
            
            if let value = c.currentPage {
                _currentPage = context.insert(of: Page.self, with: value)
            }
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _history.toArray(), recursive: true)
        context.customRemove(objects: [_UTM, _geo, _chatStartPage, _currentPage].flatten(), recursive: true)
    }
}

public final class ClientSessionGeneralChange: BaseModelChange {
    public let creationTS: TimeInterval?
    public let UTM: ClientSessionUTMGeneralChange?
    public let lastIP: String
    public let history: [PageGeneralChange]?
    public let geo: ClientSessionGeoGeneralChange?
    public let chatStartPage: PageGeneralChange?
    public let currentPage: PageGeneralChange?
    
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
