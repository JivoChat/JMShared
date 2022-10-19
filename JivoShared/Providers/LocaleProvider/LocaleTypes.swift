//
//  LocaleTypes.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 02/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JMTimelineKit

public let loc = Localizer()

public extension Notification.Name {
    static let localeChanged = Notification.Name("LocaleChanged")
}
public enum LocalizedMetaMode {
    case key(String)
    case format(String)
    case exact(String)
}

public struct SignupCountry {
    public let code: String
    public let title: String
}

public struct Localizer {
    private var classFromBundle: AnyClass?
    
    public subscript(_ keys: String..., lang lang: String? = nil) -> String {
        var result = String()
        
        for key in keys {
            if let lang = lang {
                let bundle = LocaleProvider.obtainBundle(lang: lang)
                result = bundle.localizedString(forKey: key, value: nil, table: nil)
            }
            else if let bundle = classFromBundle.flatMap({
                LocaleProvider.obtainBundle(for: $0, lang: LocaleProvider.activeLocale?.langID ?? Locale.current.langID ?? "")
            })
            ?? LocaleProvider.activeBundle {
                let value = bundle.localizedString(forKey: key, value: nil, table: nil)
                if value == key {
                    let bundle = LocaleProvider.baseLocaleBundle
                    result = bundle?.localizedString(forKey: key, value: nil, table: nil) ?? value
                }
                else {
                    result = value
                }
            }
            else {
                result = NSLocalizedString(key, comment: "")
            }
            
            if result != key {
                break
            }
        }
        
        return result
    }
    
    public subscript(key key: String, lang: String? = nil) -> String {
        return self[key, lang: lang]
            .replacingOccurrences(of: "%s", with: "%@")
            .replacingOccurrences(of: "$s", with: "$@")
    }
    
    public subscript(format key: String, _ arguments: CVarArg...) -> String {
        let locale = LocaleProvider.activeLocale
        return String(format: self[key: key], locale: locale, arguments: arguments)
    }
    
    public init(for classFromBundle: AnyClass? = nil) {
        self.classFromBundle = classFromBundle
    }
}
public func locale() -> Locale {
    return LocaleProvider.activeLocale
}
