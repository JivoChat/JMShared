//
//  JVClientSessionGeo+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVClientSessionGeo {
    public var country: String? {
        return _country?.jv_valuable
    }
    
    public var region: String? {
        return _region?.jv_valuable
    }
    
    public var city: String? {
        return _city?.jv_valuable
    }
    
    public var organization: String? {
        return _organization?.jv_valuable
    }
    
    public var countryCode: String? {
        return _countryCode?.jv_valuable?.lowercased()
    }
}
