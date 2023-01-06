//
//  JVMessageSnippet+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVMessageSnippet {
    public var URL: URL? {
        if let link = _URL, let url = NSURL(string: link) {
            return url as URL
        }
        else {
            return nil
        }
    }
    
    public var title: String {
        return _title
    }
    
    public var iconURL: URL? {
        if let link = _iconURL, let url = NSURL(string: link) {
            return url as URL
        }
        else {
            return nil
        }
    }
    
    public var HTML: String {
        return _HTML
    }
}
