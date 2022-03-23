//
//  StringExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 08/06/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import TypedTextAttributes

public extension String {
    enum SearchingMode {
        case plain
        case email
        case phone
    }
    init(_ value: String?) {
        self = value ?? String()
    }
    
    var valuable: String? {
        return isEmpty ? nil : self
    }
    
    var fileExtension: String? {
        if let ext = split(separator: ".").last {
            return String(ext)
        }
        else {
            return nil
        }
    }
    
    func appendingPathComponent(_ component: String) -> String {
        return NSString(string: self).appendingPathComponent(component)
    }
    
    func escape() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
    
    func unescape() -> String? {
        return removingPercentEncoding
    }

    func fromHTML() -> String {
        return NSString(string: self).replacingOccurrences(of: "&nbsp;", with: "\u{00a0}")
    }

    func unbreakable() -> String {
        return (self as NSString).replacingOccurrences(of: " ", with: " ")
    }

    func substringFrom(index: Int) -> String {
        if count < index {
            return self
        }
        else {
            let pointer = self.index(startIndex, offsetBy: index)
            return String(self[pointer...])
        }
    }

    func substringTo(index: Int) -> String {
        if count <= index {
            return self
        }
        else {
            let pointer = self.index(startIndex, offsetBy: index)
            return String(self[...pointer])
        }
    }
    
    func stringByRemovingSymbols(of set: CharacterSet) -> String {
        return components(separatedBy: set).joined()
    }
    
    func stringByRemoving(_ strings: [String]) -> String {
        return strings.reduce(self) { result, string in
            return result.replacingOccurrences(of: string, with: "")
        }
    }
    
    func trimmed(charset: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: charset)
    }
    
    func trimmedZeros() -> String {
        let zeroCharset = CharacterSet(charactersIn: "\u{0000}")
        let charset = CharacterSet.whitespacesAndNewlines.union(zeroCharset)
        return trimmed(charset: charset)
    }
    
    func parseDateUsingFullFormat() -> Date? {
        let dateParser = DateFormatter()
        dateParser.locale = locale()
        dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateParser.timeZone = TimeZone(identifier: "GMT")
        
        if let downToSeconds = split(separator: ".").first {
            return dateParser.date(from: String(downToSeconds))
        }
        else {
            return dateParser.date(from: self)
        }
    }
    
    func search(_ mode: SearchingMode, query: String) -> Bool {
        switch mode {
        case .plain: return lowercased().contains(query.lowercased())
        case .email: return lowercased().contains(query.lowercased())
        case .phone: return extractingPhoneSymbols().contains(query.lowercased())
        }
    }
    
    func toInt() -> Int {
        return (self as NSString).integerValue
    }

    func toHexInt() -> UInt64? {
        return valuable.flatMap({ UInt64($0, radix: 16) })
    }
    
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    
    func toBool() -> Bool {
        switch self {
        case "true", "1": return true
        case "false", "0": return false
        default: return (self as NSString).boolValue
        }
    }
    
    func extractingPhoneSymbols() -> String {
        let charset = CharacterSet(charactersIn: "+(0123456789)-")
        return components(separatedBy: charset.inverted).joined()
    }
    
    func clipBy(_ limit: Int?) -> String {
        guard let limit = limit else { return self }
        guard count >= limit else { return self }
        return substringTo(index: limit) + "…"
    }
    
    func plain() -> String {
        var result = self
        result = result.replacingOccurrences(of: "\r\n", with: " ")
        result = result.replacingOccurrences(of: "\r", with: " ")
        result = result.replacingOccurrences(of: "\n", with: " ")
        return result
    }
    
    func oneEmojiString() -> String? {
        let clearString = trimmed()
        return clearString.hasEmojiOnly ? clearString : nil
    }
    
    func containsSymbols(from characterSet: CharacterSet) -> Bool {
        return components(separatedBy: characterSet).count > 1
    }
    
    func contains(only symbols: CharacterSet) -> Bool {
        let slices = (self as NSString).components(separatedBy: symbols)
        return (slices.filter(\.isEmpty).count == unicodeScalars.count + 1)
    }

    func styledWith(lineHeight: CGFloat? = nil, foregroundColor: UIColor? = nil) -> NSAttributedString {
        var attributes = TextAttributes()
        if let value = lineHeight { attributes = attributes.minimumLineHeight(value).maximumLineHeight(value) }
        if let value = foregroundColor { attributes = attributes.foregroundColor(value) }
        return NSAttributedString(string: self, attributes: attributes)
    }

    func convertToNonBreakable() -> String {
        // replace regular space with non-break space
        return replacingOccurrences(of: " ", with: " ")
    }

    func quoted() -> String {
        return "\"\(self)\""
    }
    
    func convertToEmojis() -> String {
        return String(
            String.UnicodeScalarView(
                split(separator: "-")
                    .compactMap { UInt32($0, radix: 16) }
                    .compactMap(UnicodeScalar.init)
            )
        )
    }
    
    var hasEmojiOnly: Bool {
        guard let firstScalar = unicodeScalars.first else {
            return false
        }
        
        guard #available(iOS 10.2, *) else {
            return firstScalar.isEmoji
        }
        
        for scalarProperties in unicodeScalars.map(\.properties) {
            if scalarProperties.isEmoji, scalarProperties.isEmojiPresentation {
                continue
            }
            else if scalarProperties.isEmojiModifier {
                continue
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    var hasAnyEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else {
            return false
        }
        
        guard #available(iOS 10.2, *) else {
            return firstScalar.isEmoji
        }
        
        for scalarProperties in unicodeScalars.map(\.properties) {
            if scalarProperties.isEmoji, scalarProperties.isEmojiPresentation {
                return true
            }
            else if scalarProperties.isEmojiModifier {
                return true
            }
            else {
                continue
            }
        }
        
        return false
    }
}

public extension String.StringInterpolation {
    mutating func appendInterpolation(dashed string: String?) {
        appendLiteral(string ?? "-")
    }
}

fileprivate extension UnicodeScalar {
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F: return true // Emoticons
        case 0x1F300...0x1F5FF: return true // Misc Symbols and Pictographs
        case 0x1F680...0x1F6FF: return true // Transport and Map
        case 0x1F1E6...0x1F1FF: return true // Regional country flags
        case 0x2600...0x26FF: return true   // Misc symbols
        case 0x2700...0x27BF: return true   // Dingbats
        case 0xFE00...0xFE0F: return true   // Variation Selectors
        case 0x1F900...0x1F9FF: return true // Supplemental Symbols and Pictographs
        case 127000...127600: return true   // Various asian characters
        case 65024...65039: return true     // Variation selector
        case 9100...9300: return true       // Misc items
        case 8400...8447: return true       // Combining Diacritical Marks for Symbols
        default: return false
        }
    }
}
