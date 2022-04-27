//
//  URLExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 31/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import SafeURL
import CoreLocation
import SwiftyNSException

public enum URLCommand {
    case addContact(phone: String, name: String)
}

public extension URL {
    static func generateAvatarURL(ID: UInt64) -> (image: UIImage?, color: UIColor?) {
        let names = [
            "airplane", "apple", "ball", "bug" /*bee*/,
            "bug", "cat", "cloud", "coffee",
            "compass", "cookie", "crocodile", "diamond",
            "dolphin", "duck", "fish", "flag",
            "ghost", "glass", "leaf", "light",
            "night", "octopus", "owl", "panda",
            "penguin", "pinetree", "pizza", "robot",
            "rocket", "saxophone", "star1",
            "sun", "sword", "tie", "trafficlight",
            "umbrella", "whale", "wolf"
        ]

        let colors = [
            "9D28B2", "673AB7", "3D4EB8", "00A8F7",
            "00CBD4", "009788", "49B04C", "8BC34A"
        ]

        let name = "zoo_" + names[Int(ID % UInt64(names.count - 1))]
        let color = colors[Int(ID % UInt64(colors.count - 1))]
        
        return (
            image: UIImage(named: name),
            color: UIColor(hex: color)
        )
    }

    static func privacy() -> URL? {
        return URL(string: UIApplication.openSettingsURLString)
    }
    
    static func welcome() -> URL? {
        let link = loc["Menu.VisitWeb.URL"]
        return URL(string: link)
    }
    
    static func recoverPassword(domain: String, email: String, lang: String) -> URL? {
        return URL(string: "https://admin.\(domain)")?.build(
            "/auth/forgot-password",
            query: ["email": email, "lang": lang]
        )
    }
    
    static func mailto(mail: String) -> URL? {
        return URL(string: "mailto:\(mail)")
    }
    
    static func call(phone: String, countryCode: String?) -> URL? {
        let badSymbols = NSCharacterSet(charactersIn: "+0123456789").inverted
        let goodPhone = phone.stringByRemovingSymbols(of: badSymbols)
        let goodCountryCode = countryCode ?? String()
        return URL(string: "tel:\(goodPhone)?\(goodCountryCode)")
    }
    
    static func location(coordinate: CLLocationCoordinate2D) -> URL? {
        return URL(string: "http://maps.apple.com/maps")?.build(
            query: ["saddr": "\(coordinate.latitude),\(coordinate.longitude)"]
        )
    }
    
    static func review(applicationID: Int) -> URL? {
        return URL(string: "itms-apps://itunes.apple.com/app/id\(applicationID)")?.build(
            query: ["action": "write-review"]
        )
    }
    
    static func notificationAck(host: String, siteID: Int, agentID: Int, pushID: String) -> URL? {
        return URL(string: "https://\(host)/push/delivery/\(siteID)/\(agentID)/\(pushID)")?.build(
            query: ["platform": "ios"]
        )
    }
    
    static func customerAckEndpoint() -> URL? {
        return URL(string: "https://track.customer.io/push/events")
    }
    
    static func license() -> URL? {
        let link = loc["License.PricingURL"]
        return URL(string: link)
    }
    
    static func commandAddContact(phone: String, name: String) -> URL? {
        return URL(string: "internal://add-contact")?
            .build(query: ["phone": phone, "name": name])
    }

    static func widgetSumulator(domain: String, siteLink: String, channelID: String, codeHost: String?, lang: String) -> URL? {
        return URL(string: "https://app.\(domain)/simulate_widget.html")?.build(
            query: [
                "site": siteLink,
                "widget_id": channelID,
                "locale": lang,
                "code_host": codeHost ?? "code"
            ]
        )
    }

    static func privacyPolicy() -> URL? {
        let link = loc["Signup.PrivacyPolicy.Link"]
        return URL(string: link)
    }
    
    static func feedback(domain: String, session: String, lang: LocaleLang, siteID: Int, agentID: Int, name: String, app: String, design: String) -> URL? {
        /*
         ru: jivosite.ru
         en: jivochat.com
         pt: jivochat.com.br
         ptEu: jivochat.pt
         es: jivochat.es
         de: jivochat.de
         id: jivochat.co.id
         tr: jivochat.com.tr
         ng: jivochat.ng
         ke: jivochat.co.ke
         za: jivochat.co.za
         esAr: jivochat.com.ar
         cl: jivochat.cl
         bo: jivochat.com.bo
         mx: jivochat.mx
         ve: jivochat.com.ve
         co: jivochat.com.co
         pe: jivochat.com.pe
         in: jivochat.co.in
         uk: jivochat.co.uk
         nl: jivochat.nl
         gh: jivochat.com.gh
         */
        
        let endpoint: String // = "https://ip.yandex.ru/"/.
        #if ENV_DEBUG
        endpoint = "https://\(lang.developmentPrefix).site.dev.\(domain)/feedback"
        #else
        endpoint = "https://\(lang.productionHost)/feedback"
        #endif
        
        return URL(string: endpoint)?.build(
            query: ["session": session, "siteid": siteID, "agentid": agentID, "name": name, "description": app, "design": design]
        )
    }
    
//    static func twemoji(code: String) -> URL? {
//        guard let slice = code.split(separator: "-").first?.lowercased() else { return nil }
//        return URL(string: "https://twemoji.maxcdn.com/2/72x72/\(slice).png")
//    }

    func parseCommand() -> URLCommand? {
        if let host = host {
            var params = [String: String]()
            if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
                components.queryItems?.forEach { params[$0.name] = $0.value }
            }
            
            switch host {
            case "add-contact":
                guard let phone = params["phone"] else { return nil }
                guard let name = params["name"] else { return nil }
                return URLCommand.addContact(phone: phone, name: name)

            default:
                return nil
            }
        }
        else {
            return nil
        }
    }

    func fileSize() -> Int64? {
        guard isFileURL else { return nil }
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
        guard let size = attributes[.size] as? NSNumber else { return nil }
        return size.int64Value
    }
    
    var debugQuerylessFull: String {
        guard var c = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return String() }
        c.queryItems = nil
        return c.url?.absoluteString ?? absoluteString
    }
    
    var debugQuerylessCompact: String {
        return path
    }
    
    var debugFull: String {
        guard let c = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return String() }
        let queries: [String] = (c.queryItems ?? []).map({ item in "\t&\(item.name)=\(item.value ?? String())\n" })
        return "\(debugQuerylessFull)?\n\(queries.joined())"
    }
    
    var debugCompact: String {
        return debugQuerylessCompact
    }
    
    var utmHumanReadable: String? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let source = queryItems.value(forName: "utm_source"),
            let campaign = queryItems.value(forName: "utm_campaign")
            else { return nil }
        
        let medium = queryItems.value(forName: "utm_medium") ?? String()
        let keyword = queryItems.value(forName: "utm_term") ?? String()
        let content = queryItems.value(forName: "utm_content") ?? String()
        
        return JVClientSessionUTM.generateHumanReadable(
            source: source,
            medium: medium,
            campaign: campaign,
            keyword: keyword,
            content: content
        )
    }
    
    func unarchive<T: Codable>(type: T.Type) -> T? {
        let filePath = path
        return try? handle({ NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? T })
    }
    
    func normalized() -> URL {
        guard URLComponents(url: self, resolvingAgainstBaseURL: false)?.scheme == nil else { return self }
        return URL(string: "http://" + absoluteString) ?? self
    }
    
    func excludedFromBackup() -> URL {
        var duplicate = self
        
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? duplicate.setResourceValues(values)
        
        return duplicate
    }
}

public extension URLRequest {
    var debugFull: String {
        guard let url = url else { return String() }
        guard let c = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return String() }

        let queries: [String] = (c.queryItems ?? []).map({ item in "\t&\(item.name)=\(item.value ?? String())\n" })
        let body = httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? String()

        return "\(url.debugQuerylessFull)?\n\(queries.joined())\n\(body)"
    }

    var debugCompact: String {
        guard let url = url else { return String() }
        return url.debugCompact
    }
}

public extension URLResponse {
    var debugFull: String {
        guard let url = url else { return String() }

        if let http = self as? HTTPURLResponse {
            return "\(url.debugQuerylessFull) status[\(http.statusCode)]\n"
        }
        else {
            return url.debugQuerylessFull
        }
    }

    var debugCompact: String {
        guard let url = url else { return String() }
        
        if let http = self as? HTTPURLResponse {
            return "\(url.debugQuerylessCompact) status[\(http.statusCode)]"
        }
        else {
            return url.debugQuerylessCompact
        }
    }
}

public extension Array where Element == URLQueryItem {
    func value(forName name: String) -> String? {
        guard let item = first(where: { $0.name == name }) else { return nil }
        return item.value
    }
}

public extension LocaleLang {
    var developmentPrefix: String {
        switch self {
        case .en: return "en"
        case .ru: return "ru"
        case .es: return "es"
        case .pt: return "pt"
        case .tr: return "tr"
        }
    }
    
    var productionHost: String {
        switch self {
        case .ru: return "jivosite.\(productionDomain)"
        default: return "jivochat.\(productionDomain)"
        }
    }
    
    var productionDomain: String {
        switch self {
        case .en: return "com"
        case .ru: return "ru"
        case .es: return "es"
        case .pt: return "com.br"
        case .tr: return "com.tr"
        }
    }
    
    var feedbackEmail: String {
        switch self {
        case .tr: return "bilgi@\(productionHost)"
        default: return "info@\(productionHost)"
        }
    }
}
