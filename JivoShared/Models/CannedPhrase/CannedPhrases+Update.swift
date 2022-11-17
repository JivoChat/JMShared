//
//  CannedPhrases+Update.swift
//  JMShared
//
//  Created by Yulia Popova on 31.10.2022.
//

import Foundation
import JMCodingKit

public class CannedPhrasesChange: BaseModelChange {
    public let version: Int
    public let cannedPhrases: [CannedPhraseChange]

    required public init( json: JsonElement) {
        version = json["version"].intValue
        cannedPhrases = json["canned_phrases"].parseList() ?? []
        super.init(json: json)
    }
}
