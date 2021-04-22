//
//  ClientCustomData+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension ClientCustomData {
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
            return Foundation.URL(string: normalizedLink(link))
        }
        else if let link = content.valuable {
            return Foundation.URL(string: normalizedLink(link))
        }
        else {
            return nil
        }
    }
    
    private func normalizedLink(_ link: String) -> String {
        guard URLComponents(string: link)?.scheme == nil else { return link }
        return "http://" + link
    }
}
