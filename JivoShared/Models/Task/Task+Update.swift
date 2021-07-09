//
//  Task+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension Task {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? TaskGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _siteID = c.siteID ?? 0
            _clientID = c.clientID ?? 0
            _agent = context.agent(for: c.agentID, provideDefault: true)
            _text = c.text
            _createdTimestamp = c.createdTs ?? _createdTimestamp
            _modifiedTimestamp = c.modifiedTs ?? _modifiedTimestamp
            _notifyTimestamp = c.notifyTs
            _status = c.status
        }
        else if let _ = change as? TaskCompleteChange {
            _status = "completed"
        }
    }
}

public final class TaskGeneralChange: BaseModelChange, NSCoding {
    public let ID: Int
    public let siteID: Int?
    public let clientID: Int?
    public let agentID: Int
    public let text: String
    public let createdTs: TimeInterval?
    public let modifiedTs: TimeInterval?
    public let notifyTs: TimeInterval
    public let status: String

    private let codableIdKey = "id"
    private let codableSiteKey = "site"
    private let codableClientKey = "client"
    private let codableAgentKey = "agent"
    private let codableTextKey = "text"
    private let codableCreatedKey = "created_ts"
    private let codableModifiedKey = "updated_ts"
    private let codableTimepointKey = "timepoint"
    private let codableStatusKey = "status"
    
    public override var primaryValue: Int {
        return ID
    }
    public init(ID: Int,
         agentID: Int,
         text: String,
         createdTs: TimeInterval?,
         modifiedTs: TimeInterval?,
         notifyTs: TimeInterval,
         status: String) {
        self.ID = ID
        self.siteID = nil
        self.clientID = nil
        self.agentID = agentID
        self.text = text
        self.createdTs = createdTs
        self.modifiedTs = modifiedTs
        self.notifyTs = notifyTs
        self.status = status
        super.init()
    }

    required public init( json: JsonElement) {
        ID = json["reminder_id"].intValue
        siteID = json["site_id"].int
        clientID = json["client_id"].int
        agentID = json["agent_id"].intValue
        text = json["text"].stringValue
        createdTs = json["created_ts"].double
        modifiedTs = json["updated_ts"].double
        notifyTs = TimeInterval(json["notify_ts"].doubleValue)
        status = json["status"].stringValue
        super.init(json: json)
    }
    
    public init?(coder: NSCoder) {
        ID = coder.decodeInteger(forKey: codableIdKey)
        siteID = coder.decodeObject(forKey: codableSiteKey) as? Int
        clientID = coder.decodeObject(forKey: codableClientKey) as? Int
        agentID = coder.decodeInteger(forKey: codableAgentKey)
        text = (coder.decodeObject(forKey: codableTextKey) as? String) ?? String()
        createdTs = coder.decodeObject(forKey: codableCreatedKey) as? Double
        modifiedTs = coder.decodeObject(forKey: codableModifiedKey) as? Double
        notifyTs = coder.decodeDouble(forKey: codableTimepointKey)
        status = (coder.decodeObject(forKey: codableStatusKey) as? String) ?? String()
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ID, forKey: codableIdKey)
        coder.encode(siteID, forKey: codableSiteKey)
        coder.encode(clientID, forKey: codableClientKey)
        coder.encode(agentID, forKey: codableAgentKey)
        coder.encode(text, forKey: codableTextKey)
        coder.encode(createdTs, forKey: codableCreatedKey)
        coder.encode(modifiedTs, forKey: codableModifiedKey)
        coder.encode(notifyTs, forKey: codableTimepointKey)
        coder.encode(status, forKey: codableStatusKey)
    }
}

public final class TaskCompleteChange: BaseModelChange {
    public let ID: Int

    public override var primaryValue: Int {
        return ID
    }

    public init(ID: Int) {
        self.ID = ID
        super.init()
    }

    public required init(json: JsonElement) {
        self.ID = 0
        super.init()
    }
}
