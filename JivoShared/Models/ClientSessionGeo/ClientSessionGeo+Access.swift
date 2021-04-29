//
//  ClientSessionGeo+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension ClientSessionGeo {    public var country: String? {
        return _country?.valuable
    }
        public var region: String? {
        return _region?.valuable
    }
        public var city: String? {
        return _city?.valuable
    }
        public var organization: String? {
        return _organization?.valuable
    }
        public var countryCode: String? {
        return _countryCode?.valuable?.lowercased()
    }
}
