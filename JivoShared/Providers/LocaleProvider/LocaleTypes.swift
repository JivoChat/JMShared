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

public struct LocalizedMeta {
    public let mode: LocalizedMetaMode
    public let args: [CVarArg]
    public let suffix: String?
    public let interactiveID: JMTimelineItemInteractiveID?
    
    private let loc: Localizer
    
    public init(
        mode: LocalizedMetaMode,
        args: [CVarArg],
        suffix: String?,
        interactiveID: JMTimelineItemInteractiveID?,
        localizer: Localizer
    ) {
        self.mode = mode
        self.args = args
        self.suffix = suffix
        self.interactiveID = interactiveID
        self.loc = localizer
    }
    
    public func localized() -> String {
        let base: String
        switch mode {
        case .key(let key): base = loc[key]
        case .format(let format): base = String(format: loc[format], arguments: args)
        case .exact(let string): base = string
        }
        
        if let suffix = suffix {
            return base + suffix
        }
        else {
            return base
        }
    }
}

public struct SignupCountry {
    public let code: String
    public let title: String
}

public struct Localizer {
    private var classFromBundle: AnyClass?
    
    public subscript(_ key: String, lang: String? = nil) -> String {
        let result: String

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

        return result.replacingOccurrences(of: "%s", with: "%@")
    }
    
    public subscript(format key: String, _ arguments: CVarArg...) -> String {
        return String(format: self[key], arguments: arguments)
    }
    
    public init(for classFromBundle: AnyClass? = nil) {
        self.classFromBundle = classFromBundle
    }
}
public func locale() -> Locale {
    return LocaleProvider.activeLocale
}
