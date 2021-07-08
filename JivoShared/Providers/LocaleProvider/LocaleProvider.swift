//
//  LocaleProvider.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 08/11/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public enum LocaleLang: String {
    case en
    case ru
    case es
    case pt
    case tr
    
    public var isRussian: Bool {
        return (self == .ru)
    }
}

public protocol ILocaleProvider: class {
    var availableLocales: [Locale] { get }
    var activeLocale: Locale { get set }
    var activeLang: LocaleLang { get }
    var activeRegion: SignupCountry { get }
    var isActiveRussia: Bool { get }
    func obtainCountries() -> [SignupCountry]
}

public final class LocaleProvider: ILocaleProvider {
    private let containingBundle: Bundle

    private(set) public static var activeLocale: Locale!
    
    public static var baseLocaleBundle: Bundle?
    public static var activeBundle: Bundle?

    public static func obtainBundle(for classFromBundle: AnyClass? = nil, lang: String) -> Bundle {
        let bundle = classFromBundle.flatMap({ Bundle(for: $0) }) ?? Bundle.main
        if let path = bundle.path(forResource: lang, ofType: "lproj"), let bundle = Bundle(path: path) {
            return bundle
        }

        return baseLocaleBundle ?? Bundle.main
    }
    
    public init(containingBundle: Bundle, activeLocale: Locale) {
        if let path = Bundle.main.path(forResource: "Base", ofType: "lproj") {
            LocaleProvider.baseLocaleBundle = Bundle(path: path)
        }
        
        self.containingBundle = containingBundle
        self.activeLocale = activeLocale
    }
    
    public var availableLocales: [Locale] {
        return ["en", "ru", "es", "pt", "tr"].map(Locale.init)
    }
    
    public var activeLocale: Locale {
        get {
            return LocaleProvider.activeLocale
        }
        set {
            LocaleProvider.activeLocale = newValue
            LocaleProvider.activeBundle = newValue.langID.flatMap({ LocaleProvider.obtainBundle(lang: $0) }) ?? LocaleProvider.baseLocaleBundle
            NotificationCenter.default.post(name: .localeChanged, object: containingBundle)
        }
    }
    
    public var activeLang: LocaleLang {
        guard let langID = activeLocale.langID else { return .en }
        return LocaleLang(rawValue: langID) ?? .en
    }
    
    public var activeRegion: SignupCountry {
        let countries = obtainCountries()
        let code = Locale.current.regionCode

        if let region = countries.first(where: { $0.code == code }) {
            return region
        }
        else if let firstCountry = countries.first {
            return firstCountry
        }
        else {
            abort()
        }
    }

    public var isActiveRussia: Bool {
        return (activeLang == .ru)
    }

    public func obtainCountries() -> [SignupCountry] {
        let originRegions: [SignupCountry] = Locale.isoRegionCodes.compactMap { regionCode in
            let region = Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode
            return SignupCountry(code: regionCode, title: region)
        }

        return originRegions.sorted { first, second in
            return (first.title < second.title)
        }
    }
}
