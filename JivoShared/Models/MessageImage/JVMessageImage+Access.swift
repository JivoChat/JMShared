//
//  _JVMessageImage+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension _JVMessageImage {
    public var fileName: String {
        return _fileName
    }
    
    public var URL: URL {
        return NSURL(string: _URL)! as URL
    }
    
    public var uploadDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(_uploadTS))
    }
}
