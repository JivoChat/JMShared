//  
//  JVQuickPhrase+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JVQuickPhrase {    public var ID: String {
        return _ID
    }
        public var lang: String {
        return _lang
    }
        public var tags: [String] {
        return _tags
            .components(separatedBy: QuickPhraseStorageSeparator)
            .filter { !$0.isEmpty }
    }
        public var text: String {
        return _text
    }
    
    public func export() -> JVQuickPhraseGeneralChange {
        return JVQuickPhraseGeneralChange(
            ID: ID,
            lang: lang,
            tag: tags.first ?? String(" "),
            text: text
        )
    }
}
