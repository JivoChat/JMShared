//
//  ClientSessionGeo+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JivoShared

extension ClientSessionGeo {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? ClientSessionGeoGeneralChange {
            _country = c.country
            _region = c.region
            _city = c.city
            _organization = c.organization
            _countryCode = c.countryCode
        }
    }
}

public final class ClientSessionGeoGeneralChange: BaseModelChange {
    public let country: String?
    public let region: String?
    public let city: String?
    public let organization: String?
    public let countryCode: String?
    
    required public init( json: JsonElement) {
        if let demographics = json.has(key: "demographics") {
            let location = demographics["locationDeduced"]
            country = location["country"]["name"].valuable
            region = location["state"]["name"].valuable
            city = location["city"]["name"].valuable
            organization = nil
            countryCode = location["country"]["code"].valuable
        }
        else {
            country = json["country"].valuable
            region = json["region"].valuable
            city = json["city"].valuable
            organization = json["organization"].valuable
            countryCode = json["country_code"].valuable
        }
        
        super.init(json: json)
    }
}
