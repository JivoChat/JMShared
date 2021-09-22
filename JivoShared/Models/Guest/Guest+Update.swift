//  
//  Guest+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension Guest {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? GuestBaseChange {
            if _ID == "" { _ID = c.ID }
            if _agentID == 0 { _agentID = abs(c.agentID ?? _agentID) }
            if _startDate == nil { _startDate = Date() }
            if not(c.siteID.isEmpty) { _channelID = c.siteID }
        }
        
        if !(change is GuestRemovalChange) {
            _lastUpdate = Date()
            _disappearDate = nil
        }
        
        if let c = change as? GuestGeneralChange {
            _sourceIP = c.sourceIP
            _sourcePort = c.sourcePort
            _regionCode = c.regionCode
            _countryCode = c.countryCode
            _countryName = c.countryName
            _regionName = c.regionName
            _cityName = c.cityName
            _organization = c.organization
        }
        else if let c = change as? GuestClientChange {
            _clientID = c.clientID
        }
        else if let c = change as? GuestNameChange {
            _name = c.name
        }
        else if let c = change as? GuestProactiveChange {
            _proactiveAgent = context.agent(for: c.proactiveAgentID, provideDefault: true)
        }
        else if let c = change as? GuestStatusChange {
            _status = c.status
        }
        else if let c = change as? GuestPageLinkChange {
            _pageLink = c.link
        }
        else if let c = change as? GuestPageTitleChange {
            _pageTitle = c.title
        }
        else if let c = change as? GuestStartTimeChange {
            _startDate = Date().addingTimeInterval(-c.timestamp)
        }
        else if let c = change as? GuestUTMChange {
            _utm = context.insert(of: ClientSessionUTM.self, with: c.utm)
        }
        else if let c = change as? GuestVisitsChange {
            _visitsNumber = c.number
        }
        else if let c = change as? GuestNavigatesChange {
            _navigatesNumber = c.number
        }
        else if let c = change as? GuestVisibleChange {
            _visible = c.value
        }
        else if let c = change as? GuestAgentsChange {
            let attendees = c.agentIDs.map {
                ChatAttendeeGeneralChange(
                    ID: $0,
                    relation: "attendee",
                    comment: nil,
                    invitedBy: nil,
                    isAssistant: false,
                    receivedMessageID: 0,
                    unreadNumber: 0,
                    notifications: nil
                )
            }
            
            _attendees.set(context.insert(of: ChatAttendee.self, with: attendees))
        }
        else if let c = change as? GuestWidgetVersionChange {
            _widgetVersion = c.version
        }
        else if let _ = change as? GuestUpdateChange {
            _lastUpdate = Date()
        }
        else if let _ = change as? GuestRemovalChange {
            _disappearDate = Date()
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
        context.customRemove(objects: _attendees.toArray(), recursive: true)
        context.customRemove(objects: [_utm].flatten(), recursive: true)
    }
}
public func GuestChangeParse(for item: String) -> GuestBaseChange? {
    let args = item.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
    guard args.count >= 4 else { return nil }
    
    switch args[3] {
    case "+": return GuestGeneralChange(arguments: args)
    case "cid": return GuestClientChange(arguments: args)
    case "name": return GuestNameChange(arguments: args)
    case "status": return GuestStatusChange(arguments: args)
    case "pa_id": return GuestProactiveChange(arguments: args)
    case "purl": return GuestPageLinkChange(arguments: args)
    case "ptitle": return GuestPageTitleChange(arguments: args)
    case "startsec": return GuestStartTimeChange(arguments: args)
    case "utm": return GuestUTMChange(arguments: args)
    case "visits": return GuestVisitsChange(arguments: args)
    case "navcount": return GuestNavigatesChange(arguments: args)
    case "visible": return GuestVisibleChange(arguments: args)
    case "agentids": return GuestAgentsChange(arguments: args)
    case "wversion": return GuestWidgetVersionChange(arguments: args)
    case "-": return GuestRemovalChange(arguments: args)
    default: return nil
    }
}
open class GuestBaseChange: BaseModelChange {
    public let ID: String
    public let siteID: String
    public let agentID: Int?
    
    open override var stringKey: DatabaseContextMainKey<String>? {
        return DatabaseContextMainKey(key: "_ID", value: ID)
    }
        public init(ID: String) {
        self.ID = ID
        self.siteID = String()
        self.agentID = nil
        super.init()
    }
        public init(arguments: [String]) {
        ID = arguments.stringOrEmpty(at: 0)
        siteID = arguments.stringOrEmpty(at: 1)
        agentID = arguments.stringOrEmpty(at: 2).toInt()
        super.init()
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
    
    open override var isValid: Bool {
        guard !ID.isEmpty else { return false }
        guard !siteID.isEmpty else { return false }
        return true
    }
}
open class GuestGeneralChange: GuestBaseChange {
    public let sourceIP: String
    public let sourcePort: Int
    public let regionCode: Int
    public let countryCode: String
    public let countryName: String
    public let regionName: String
    public let cityName: String
    public let organization: String
    
    override init(arguments: [String]) {
        sourceIP = arguments.stringOrEmpty(at: 4)
        sourcePort = arguments.stringOrEmpty(at: 5).toInt()
        regionCode = arguments.stringOrEmpty(at: 6).toInt()
        countryCode = arguments.stringOrEmpty(at: 7)
        countryName = arguments.stringOrEmpty(at: 8)
        regionName = arguments.stringOrEmpty(at: 9)
        cityName = arguments.stringOrEmpty(at: 10)
        organization = arguments.stringOrEmpty(at: 13)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestClientChange: GuestBaseChange {
    public let clientID: Int

    override init(arguments: [String]) {
        clientID = arguments.stringOrEmpty(at: 4).toInt()
        super.init(arguments: arguments)
    }

    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestStatusChange: GuestBaseChange {
    public let status: String
    
    override init(arguments: [String]) {
        status = arguments.stringOrEmpty(at: 4)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestProactiveChange: GuestBaseChange {
    public let proactiveAgentID: Int
    
    override init(arguments: [String]) {
        proactiveAgentID = arguments.stringOrEmpty(at: 4).toInt()
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestNameChange: GuestBaseChange {
    public let name: String
    
    override init(arguments: [String]) {
        name = arguments.stringOrEmpty(at: 4)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestPageLinkChange: GuestBaseChange {
    public let link: String
    
    override init(arguments: [String]) {
        link = arguments.stringOrEmpty(at: 4)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestPageTitleChange: GuestBaseChange {
    public let title: String
    
    override init(arguments: [String]) {
        title = arguments.stringOrEmpty(at: 4)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestStartTimeChange: GuestBaseChange {
    public let timestamp: TimeInterval
    
    override init(arguments: [String]) {
        timestamp = TimeInterval(arguments.stringOrEmpty(at: 4).toInt())
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestUTMChange: GuestBaseChange {
    private static var jsonCoder = JsonCoder()
    
    public let utm: ClientSessionUTMGeneralChange?
    
    override init(arguments: [String]) {
        utm = GuestUTMChange.jsonCoder.decode(raw: arguments.stringOrEmpty(at: 4))?.parse()
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestVisitsChange: GuestBaseChange {
    public let number: Int
    
    override init(arguments: [String]) {
        number = arguments.stringOrEmpty(at: 4).toInt()
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestNavigatesChange: GuestBaseChange {
    public let number: Int
    
    override init(arguments: [String]) {
        number = arguments.stringOrEmpty(at: 4).toInt()
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestVisibleChange: GuestBaseChange {
    public let value: Bool
    
    override init(arguments: [String]) {
        value = arguments.stringOrEmpty(at: 4).toBool()
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestAgentsChange: GuestBaseChange {
    private static var jsonCoder = JsonCoder()
    
    public let agentIDs: [Int]
    
    override init(arguments: [String]) {
        let idsArgument = arguments.stringOrEmpty(at: 4)
        
        let idsSource: String
        if idsArgument.hasPrefix("[") {
            idsSource = idsArgument
        }
        else if idsArgument == "false" {
            idsSource = "[]"
        }
        else {
            idsSource = "[\(idsArgument)]"
        }
        
        agentIDs = GuestAgentsChange.jsonCoder.decode(raw: idsSource)?.intArray ?? []
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
open class GuestWidgetVersionChange: GuestBaseChange {
    public let version: String
    
    override init(arguments: [String]) {
        version = arguments.stringOrEmpty(at: 4)
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}

public final class GuestUpdateChange: GuestBaseChange {
}
open class GuestRemovalChange: GuestBaseChange {
    override init(arguments: [String]) {
        super.init(arguments: arguments)
    }
    
    required public init(json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
}
