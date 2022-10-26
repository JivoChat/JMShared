//  
//  JVGuest.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMCodingKit

public final class JVGuest: JVBaseModel {
    @objc dynamic public var _ID: String = ""
    @objc dynamic public var _channelID: String = ""
    @objc dynamic public var _agentID: Int = 0
    @objc dynamic public var _clientID: Int = 0
    @objc dynamic public var _status: String = ""
    @objc dynamic public var _sourceIP: String = ""
    @objc dynamic public var _sourcePort: Int = 0
    @objc dynamic public var _regionCode: Int = 0
    @objc dynamic public var _countryCode: String = ""
    @objc dynamic public var _countryName: String = ""
    @objc dynamic public var _regionName: String = ""
    @objc dynamic public var _cityName: String = ""
    @objc dynamic public var _organization: String = ""
    @objc dynamic public var _name: String = ""
    @objc dynamic public var _phone: String = ""
    @objc dynamic public var _email: String = ""
    @objc dynamic public var _proactiveAgent: JVAgent?
    @objc dynamic public var _pageLink: String = ""
    @objc dynamic public var _pageTitle: String = ""
    @objc dynamic public var _startDate: Date?
    @objc dynamic public var _utm: JVClientSessionUTM?
    @objc dynamic public var _visitsNumber: Int = 0
    @objc dynamic public var _navigatesNumber: Int = 0
    @objc dynamic public var _visible: Bool = false
    @objc dynamic public var _widgetVersion: String = ""
    @objc dynamic public var _disappearDate: Date?
    @objc dynamic public var _lastUpdate: Date?
    public let _attendees = List<JVChatAttendee>()
    public let _bots = List<JVBot>()

    public override class func primaryKey() -> String? {
        return nil
    }
    
    public override func recursiveDelete(context: IDatabaseContext) {
        performDelete(inside: context)
        super.recursiveDelete(context: context)
    }
    
    public override func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
        super.apply(inside: context, with: change)
        performApply(inside: context, with: change)
    }
}
