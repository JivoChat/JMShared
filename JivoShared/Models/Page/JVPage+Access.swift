//  
//  _JVPage+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension _JVPage {
    public var URL: URL? {
        return Foundation.URL(string: _URL)
    }
    
    public var title: String {
        return _title
    }
    
    public var time: Date? {
        return _time?.jv_parseDateUsingFullFormat()
    }
}
