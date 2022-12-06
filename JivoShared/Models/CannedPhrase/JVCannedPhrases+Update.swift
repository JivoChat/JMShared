//
//  CannedPhrases+Update.swift
//  JMShared
//
//  Created by Yulia Popova on 31.10.2022.
//

import Foundation
import JMCodingKit

public class JVCannedPhrasesChange: JVBaseModelChange {
    public let version: Int
    public let cannedPhrases: [JVCannedPhraseChange]

    required public init( json: JsonElement) {
        version = json["version"].intValue
        cannedPhrases = json["canned_phrases"].parseList() ?? []
        super.init(json: json)
    }
}
