//  
//  JVTimezone+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit

extension _JVTimezone {
    public func performApply(inside context: JVIDatabaseContext, with change: JVBaseModelChange) {
        if let c = change as? JVTimezoneGeneralChange {
            let defaultTimezone = TimeZone(identifier: c.code) ?? .current
            let gmtOffset = TimeZone(identifier: c.code)?.secondsFromGMT() ?? 0
            let localeEn = Locale(identifier: "en_US")
            let localeRu = Locale(identifier: "ru_RU")
            let metaEn = extractMeta(c.displayNameEn)
            let metaRu = extractMeta(c.displayNameRu)
            
            _ID = c.ID
            _identifier = c.code
            _displayNameEn = c.displayNameEn
            _displayNameRu = c.displayNameRu
            
            _displayGMT = (metaEn ?? metaRu)?.gmt
            _sortingOffset = (metaEn ?? metaRu)?.offset ?? gmtOffset
            _sortingRegionEn = metaEn?.region ?? defaultTimezone.localizedName(for: .generic, locale: localeEn)
            _sortingRegionRu = metaRu?.region ?? defaultTimezone.localizedName(for: .generic, locale: localeRu)
        }
    }
    
    private func extractMeta(_ name: String?) -> (gmt: String, offset: Int, region: String)? {
        guard let name = name else { return nil }
        
        do {
            let regex = try NSRegularExpression(pattern: #"^\((GMT([+-])(\d{2}):(\d{2}))\)\s*(.*)\s*$"#, options: [])
            let range = NSRange(location: 0, length: name.count)
            guard let match = regex.firstMatch(in: name, options: [], range: range) else { return nil }
            
            let gmtRange = match.range(at: 1)
            let signRange = match.range(at: 2)
            let hourRange = match.range(at: 3)
            let minuteRange = match.range(at: 4)
            let regionRange = match.range(at: 5)

            let isPositive = ((name as NSString).substring(with: signRange) == "+")
            let hour = (name as NSString).substring(with: hourRange).jv_toInt()
            let minute = (name as NSString).substring(with: minuteRange).jv_toInt()
            
            return (
                gmt: (name as NSString).substring(with: gmtRange),
                offset: (hour * 3600 + minute * 60) * (isPositive ? 1 : -1),
                region: (name as NSString).substring(with: regionRange)
            )
        }
        catch {
            return nil
        }
    }
}

public final class JVTimezoneGeneralChange: JVBaseModelChange, Codable {
    private enum Keys: CodingKey {
        case ID
        case code
        case displayNameEn
        case displayNameRu
    }
    
    public let ID: Int
    public let code: String
    public let displayNameEn: String?
    public let displayNameRu: String?
    
    public override var primaryValue: Int {
        return ID
    }
    
    public override var isValid: Bool {
        guard ID > 0 else { return false }
        guard !code.isEmpty else { return false }
        return true
    }
    
    required public init( json: JsonElement) {
        ID = json["timezone_id"].intValue
        code = json["code"].stringValue
        displayNameEn = json["display_name_en"].string
        displayNameRu = json["display_name_ru"].string
        super.init(json: json)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        ID = try container.decode(Int.self, forKey: .ID)
        code = try container.decode(String.self, forKey: .code)
        displayNameEn = try container.decodeIfPresent(String.self, forKey: .displayNameEn)
        displayNameRu = try container.decodeIfPresent(String.self, forKey: .displayNameRu)

        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(ID, forKey: .ID)
        try container.encode(code, forKey: .code)
        try container.encodeIfPresent(displayNameEn, forKey: .displayNameEn)
        try container.encodeIfPresent(displayNameRu, forKey: .displayNameRu)
    }
}
