//
//  LocaleTypes.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 02/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JMTimelineKit

public let jv_loc = JVLocalizer()
internal let loc = jv_loc

public extension Notification.Name {
    static let jvLocaleDidChange = Notification.Name("LocaleDidChange")
}

public enum JVLocalizedMetaMode {
    case key(String)
    case format(String)
    case exact(String)
}

public struct JVLocalizer {
    private var classFromBundle: AnyClass?
    
    public subscript(_ keys: String..., lang lang: String? = nil) -> String {
        var result = String()
        
        for key in keys {
            if let lang = lang {
                let bundle = JVLocaleProvider.obtainBundle(lang: lang)
                result = bundle.localizedString(forKey: key, value: nil, table: nil)
            }
            else if let bundle = classFromBundle.flatMap({
                JVLocaleProvider.obtainBundle(for: $0, lang: JVLocaleProvider.activeLocale?.jv_langID ?? Locale.current.jv_langID ?? "")
            })
            ?? JVLocaleProvider.activeBundle {
                let value = bundle.localizedString(forKey: key, value: nil, table: nil)
                if value == key {
                    let bundle = JVLocaleProvider.baseLocaleBundle
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
        let locale = JVLocaleProvider.activeLocale
        return String(format: self[key: key], locale: locale, arguments: arguments)
    }
    
    public init(for classFromBundle: AnyClass? = nil) {
        self.classFromBundle = classFromBundle
    }
}

public func JVActiveLocale() -> Locale {
    return JVLocaleProvider.activeLocale
}
