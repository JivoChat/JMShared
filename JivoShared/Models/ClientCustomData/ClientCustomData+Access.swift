//
//  JVClientCustomData+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVClientCustomData {
    public var title: String? {
        return _title?.valuable
    }
    
    public var key: String? {
        return _key?.valuable
    }
    
    public var content: String {
        return _content
    }
    
    public var URL: URL? {
        if let link = _link?.valuable {
            if URLComponents(string: link)?.scheme == nil {
                return Foundation.URL(string: "https://" + link)
            }
            else {
                return Foundation.URL(string: link)
            }
        }
        else if let content = _content.valuable, content.contains("://") {
            return Foundation.URL(string: content)
        }
        else {
            return nil
        }
    }
}
