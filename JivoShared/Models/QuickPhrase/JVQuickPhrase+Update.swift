//  
//  JVQuickPhrase+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

let QuickPhraseStorageSeparator = ","

extension JVQuickPhrase {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVQuickPhraseGeneralChange {
            if _ID == "" { _ID = c.ID }
            _lang = c.lang
            _tags = ([String()] + c.tags + [String()]).joined(separator: QuickPhraseStorageSeparator)
            _text = c.text
        }
    }
}

public final class JVQuickPhraseGeneralChange: JVBaseModelChange {
    public let ID: String
    public let lang: String
    public let tags: [String]
    public let text: String
    
    public override var stringKey: JVDatabaseContextMainKey<String>? {
        return JVDatabaseContextMainKey(key: "_ID", value: ID)
    }
    
    public init(lang language: String, json: JsonElement) {
        ID = json["id"].string?.jv_valuable ?? UUID().uuidString.lowercased()
        lang = language
        tags = jv_with(json["tags"]) { $0.string.flatMap({[$0]}) ?? $0.stringArray }
        text = json["text"].stringValue
        super.init(json: json)
    }
    
    public init(ID: String,
         lang: String,
         tag: String,
         text: String) {
        self.ID = ID
        self.lang = lang
        self.tags = [tag]
        self.text = text
        super.init()
    }
    
    required public init( json: JsonElement) {
        fatalError("init(json:) has not been implemented")
    }
    
    public override var isValid: Bool {
        guard !ID.isEmpty else { return false }
        guard !lang.isEmpty else { return false }
        guard !tags.isEmpty else { return false }
        guard !text.isEmpty else { return false }
        return true
    }
    
    public func encode() -> JsonElement {
        return JsonElement(
            [
                "id": ID,
                "tags": tags,
                "text": text
            ]
        )
    }
    
    public static func ==(lhs: JVQuickPhraseGeneralChange, rhs: JVQuickPhraseGeneralChange) -> Bool {
        guard lhs.ID == rhs.ID else { return false }
        return true
    }
}
