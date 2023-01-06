//
//  JVChannel+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVChannel {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVChannelGeneralChange {
            if _ID == 0 { _ID = c.ID }
            _publicID = c.publicID
            _stateID = c.stateID
            _siteURL = c.siteURL
            _guestsNumber = c.guestsNumber
            _jointType = c.jointType ?? ""
            _agentIDs = "," + c.agentIDs.jv_stringify().joined(separator: ",") + ","
        }
    }
}

public final class JVChannelGeneralChange: JVBaseModelChange {
    public let ID: Int
    public let publicID: String
    public let stateID: Int
    public let siteURL: String
    public let guestsNumber: Int
    public let jointType: String?
    public let agentIDs: [Int]
    
    public override var primaryValue: Int {
        return ID
    }
    
    required public init( json: JsonElement) {
        let info = json["widget_info"]
        ID = info["widget_id"].intValue
        publicID = info["public_id"].stringValue
        stateID = info["widget_status_id"].intValue
        siteURL = info["site_url"].stringValue
        guestsNumber = info["visitors_insight"].intValue
        jointType = info["joint_type"].string
        agentIDs = json["agents"].intArray ?? []
        super.init(json: json)
    }
}
