//
//  JVAgent+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVDepartment {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? DepartmentGeneralChange {
            if _ID == 0 { _ID = c.id }
            _name = c.name
            _icon = c.icon
            _brief = c.brief
            
            _channelsIds = (
                c.channelsIds.isEmpty
                ? String()
                : "," + c.channelsIds.map(String.init).joined(separator: ",") + ","
            )
            
            _agentsIds = (
                c.agentsIds.isEmpty
                ? String()
                : "," + c.agentsIds.map(String.init).joined(separator: ",") + ","
            )
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
    }
}

public final class DepartmentGeneralChange: BaseModelChange, Codable {
    public let id: Int
    public let name: String
    public let icon: String
    public let brief: String
    public let channelsIds: [Int]
    public let agentsIds: [Int]

    public override var primaryValue: Int {
        return id
    }
    
    public required init(json: JsonElement) {
        id = json["group_id"].intValue
        name = json["name"].stringValue
        icon = json["icon"].stringValue
        brief = json["description"].stringValue
        channelsIds = json["widget_ids"].intArray ?? Array()
        agentsIds = json["agent_ids"].intArray ?? Array()

        super.init(json: json)
    }
}
