//
//  JVAgent+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension JVBot {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? BotGeneralChange {
            if _id == 0 { _id = c.id }
            _avatarLink = c.avatarLink?.valuable
            _displayName = c.displayName ?? String()
            _title = c.title ?? String()
        }
    }
    
    public func performDelete(inside context: IDatabaseContext) {
    }
}

public final class BotGeneralChange: BaseModelChange, Codable {
    public let id: Int
    public let avatarLink: String?
    public let displayName: String?
    public let title: String?
    
    public override var primaryValue: Int {
        return id
    }
    
    public required init(json: JsonElement) {
        id = json["bot_id"].intValue
        avatarLink = json["avatar_url"].string
        displayName = json["display_name"].string
        title = json["title"].string
        
        super.init(json: json)
    }
    
    public init(placeholderID: Int) {
        id = placeholderID
        avatarLink = nil
        displayName = nil
        title = nil

        super.init()
    }
    
    public init(id: Int,
                avatarLink: String?,
                displayName: String?,
                title: String?) {
        self.id = id
        self.avatarLink = avatarLink
        self.displayName = displayName
        self.title = title
        super.init()
    }
    
    public func cachable() -> BotGeneralChange {
        return BotGeneralChange(
            id: id,
            avatarLink: avatarLink,
            displayName: displayName,
            title: title)
    }
}
