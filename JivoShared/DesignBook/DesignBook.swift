//
//  DesignBook.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 04/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMShared
import JMRepicKit

fileprivate var sharedInstance: DesignBook!
fileprivate let dynamicFontEnabled = true
fileprivate let usingForcedStyle: DesignBookStyle? = nil
fileprivate var initialStatusBarHeight = CGFloat.zero

public final class DesignBook {
    public static var shared: DesignBook {
        return sharedInstance
    }
    
    private let window: UIWindow
    private var lastStyleTraits: UITraitCollection
    private var styleObservable = BroadcastTool<DesignBookStyle>()
    
    public init(window: UIWindow) {
        self.window = window
        
        lastStyleTraits = window.traitCollection
        initialStatusBarHeight = UIApplication.shared.statusBarFrame.height
        sharedInstance = self
    }
    
    public func addObserver(block: @escaping (DesignBookStyle) -> Void) -> BroadcastObserver<DesignBookStyle> {
        return styleObservable.addObserver(block)
    }
    
    public func removeObserver(observer: BroadcastObserver<DesignBookStyle>) {
        styleObservable.removeObserver(observer)
    }

    public func update() {
        if #available(iOS 12.0, *) {
            guard window.traitCollection.userInterfaceStyle != lastStyleTraits.userInterfaceStyle else { return }
            lastStyleTraits = window.traitCollection
            
            let style = lastStyleTraits.toDesignStyle
            styleObservable.broadcast(style)
        }
    }
    
    public class func screenSize() -> DesignBookScreenSize {
        let idiom = UI_USER_INTERFACE_IDIOM()
        let scale = UIScreen.main.nativeScale
        let height = UIScreen.main.nativeBounds.height / scale
        
        switch true {
        case idiom == .pad: return .extraLarge
        case height > 850 where scale >= 3: return .extraLarge
        case height > 850: return .large
        case height > 700 where initialStatusBarHeight == 50: return .standard
        case height > 700: return .large
        case height > 600: return .standard
        default: return .small
        }
    }
    
    public class func systemIcon(_ systemName: String, orStandard name: String, pointSize: CGFloat? = nil, tintColor: UIColor? = nil) -> UIImage? {
        if #available(iOS 13.0, *) {
            let config: UIImage.SymbolConfiguration
            if let size = pointSize {
                config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
            }
            else {
                config = UIImage.SymbolConfiguration(weight: .medium)
            }
            
            let base = UIImage(systemName: systemName)?.applyingSymbolConfiguration(config)
            if let color = tintColor {
                return base?.withTintColor(color, renderingMode: .alwaysOriginal)
            }
            else {
                return base?.withRenderingMode(.alwaysTemplate)
            }
        }
        else {
            return UIImage(named: name, in: Bundle(for: DesignBook.self), compatibleWith: nil)
        }
    }

    public class func backIcon(pointSize: CGFloat? = nil) -> UIImage? {
        return systemIcon("chevron.left", orStandard: "nav_back", pointSize: pointSize)
    }
    
    public class func checkIcon() -> UIImage? {
        return systemIcon("checkmark", orStandard: "cell_check")
    }
    
    public class func forwardIcon() -> UIImage? {
        return systemIcon("chevron.right", orStandard: "nav_forward")
    }
    
    public class func dotsIcon() -> UIImage? {
        return systemIcon("ellipsis", orStandard: "dots")
    }
    
    public let layout = DesignBookLayout(
        sideMargin: 32,
        controlMargin: 15,
        controlBigRadius: 8,
        controlSmallRadius: 2,
        alertRadius: 12,
        defaultMediaRatio: 0.6
    )
    
    private let colors: [DesignBookStyle: [DesignBookColorAlias: UIColor]] = [
        .light: [
            .darkBackground: UIColor(hex: 0x1C1B17),
            .white: UIColor.white,
            .black: UIColor.black,
            .background: UIColor(hex: 0xF7F9FC),
            .stillBackground: UIColor(hex: 0xF7F7F7),
            .silverLight: UIColor(hex: 0xD1D1D6),
            .silverRegular: UIColor(hex: 0xC7C7CC),
            .steel: UIColor(hex: 0x8E8E93),
            .grayLight: UIColor(hex: 0xEFEFF4),
            .grayRegular: UIColor(hex: 0xE9EBF0),
            .grayDark: UIColor(hex: 0xE5E5EA),
            .tangerine: UIColor(hex: 0xFF9500),
            .sunflowerYellow: UIColor(hex: 0xFFCC00),
            .reddishPink: UIColor(hex: 0xFF2D55),
            .orangeRed: UIColor(hex: 0xFF3B30),
            .greenLight: UIColor(hex: 0x4CD964),
            .greenJivo: UIColor(hex: 0x00BA3B),
            .skyBlue: UIColor(hex: 0x5AC8FA),
            .brightBlue: UIColor(hex: 0x007AFF),
            .darkPeriwinkle: UIColor(hex: 0x5856D6),
            .seashell: UIColor(hex: 0xF1F0F0),
            .alto: UIColor(hex: 0xDEDEDE),
            .unknown1: UIColor(hex: 0xB7B7BC),
            .unknown2: UIColor(hex: 0x59595E),
            .unknown3: UIColor(hex: 0x009627),
            .unknown4: UIColor(hex: 0xFAFAFB),
            .unknown5: UIColor(hex: 0xA4B4BC),
            .color_ff2f0e: UIColor(hex: 0xFF2F0E),
            .color_00bc31: UIColor(hex: 0x00BC31)
        ],
        .dark: [
            .white: UIColor.white,
            .black: UIColor.black,
            .orangeRed: UIColor(hex: 0xFF3B30),
            .greenJivo: UIColor(hex: 0x008A0B),
            .sunflowerYellow: UIColor(hex: 0xFFCC00),
            .silverRegular: UIColor(hex: 0xC7C7CC),
            .grayDark: UIColor(hex: 0xE5E5EA),
            .greenLight: UIColor(hex: 0x4CD964),
            .reddishPink: UIColor(hex: 0xFF2D55),
            .steel: UIColor(hex: 0x8E8E93),
            
            .darkBackground: UIColor(hex: 0x1C1B17),
            .background: UIColor(hex: 0xF7F9FC),
            .stillBackground: UIColor(hex: 0xF7F7F7),
            .silverLight: UIColor(hex: 0xD1D1D6),
            .grayRegular: UIColor(hex: 0xE9EBF0),
            .tangerine: UIColor(hex: 0xFF9500),
            .skyBlue: UIColor(hex: 0x5AC8FA),
            .brightBlue: UIColor(hex: 0x307AFF),
            .darkPeriwinkle: UIColor(hex: 0x5856D6),
            .unknown1: UIColor(hex: 0xC7C7CC),
            .unknown2: UIColor(hex: 0x59595E),
            .unknown3: UIColor(hex: 0x009627),
            .unknown4: UIColor(hex: 0xFAFAFB),
            .unknown5: UIColor(hex: 0xA4B4BC),
            .color_ff2f0e: UIColor(hex: 0xFF2F0E),
            .color_00bc31: UIColor(hex: 0x00BC31)
        ]
    ]
    
    public func currentLogo() -> UIImage? {
        switch locale().langID ?? "en" {
        case "ru": return UIImage(named: "logo_ru")
        default: return UIImage(named: "logo_int")
        }
    }
    
    public func currentMiniLogo() -> UIImage? {
        switch locale().langID ?? "en" {
        case "ru": return UIImage(named: "mini-logo-ru")
        default: return UIImage(named: "mini-logo-int")
        }
    }
    
    public func color(_ color: DesignBookColor, style: DesignBookStyle = .light) -> UIColor {
        switch color {
        case .native(let value): return value
        case .hex(let hex): return obtainColor(byHex: hex)
        case .alias(let alias): return obtainColor(forStyle: style, withAlias: alias)
        case .usage(let usage): return obtainColor(forUsage: usage)
        }
    }
    
    public func color(hex: Int) -> UIColor {
        return color(.hex(hex))
    }
    
    public func color(alias: DesignBookColorAlias) -> UIColor {
        return color(.alias(alias))
    }
    
    public func color(usage: DesignBookColorUsage) -> UIColor {
        return color(.usage(usage))
    }
    
    public func font(weight: DesignBookFontWeight, category: UIFont.TextStyle, defaultSizes: DesignBookFontSize, maximumSizes: DesignBookFontSize?) -> UIFont {
        let defaultFont: UIFont = convert(weight) { value in
            let defaultSize = extractFontSize(defaultSizes)
            switch value {
            case .italics: return UIFont.italicSystemFont(ofSize: defaultSize)
            default: return UIFont.systemFont(ofSize: defaultSize, weight: adjustedFontWeight(value))
            }
        }
        
        if dynamicFontEnabled {
            if #available(iOS 11.0, *) {
                let maximumSize = maximumSizes.flatMap(extractFontSize) ?? .infinity
                return UIFontMetrics(forTextStyle: category).scaledFont(for: defaultFont, maximumPointSize: maximumSize)
            }
            else {
                let dynamicDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: category)
                
                if let maximumSize = maximumSizes.flatMap(extractFontSize) {
                    let pointSize = min(maximumSize, dynamicDescriptor.pointSize)
                    return defaultFont.withSize(pointSize)
                }
                else {
                    return defaultFont.withSize(dynamicDescriptor.pointSize)
                }
            }
        }
        else {
            return defaultFont
        }
    }
    
    public func numberOfLines(standard: Int) -> Int {
        let dynamicDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        
        switch dynamicDescriptor.pointSize {
        case -.infinity ..< 19: return standard
        case 19 ..< 28: return standard + 1
        case 28 ..< .infinity: return standard + 2
        default: abort()
        }
    }
    
    public func scaledValue(_ value: CGFloat, category: UIFont.TextStyle, multiplier: CGFloat = 1.0, maximum: CGFloat? = nil) -> CGFloat {
        let result: CGFloat
        if #available(iOS 11.0, *) {
            result = UIFontMetrics(forTextStyle: category).scaledValue(for: value)
        }
        else {
            result = value
        }
        
        if let maximum = maximum {
            return min(maximum, result) * multiplier
        }
        else {
            return result * multiplier
        }
    }
    
    public func scaledSize(_ size: CGSize, category: UIFont.TextStyle, multiplier: CGFloat = 1.0) -> CGSize {
        return CGSize(
            width: scaledValue(size.width, category: category, multiplier: multiplier),
            height: scaledValue(size.height, category: category, multiplier: multiplier)
        )
    }
    
    public func configureMetaControl(_ control: JMRepicView, for attendees: [Presentable], transparent: Bool, repicContext: JMRepicView.VisualContext, primaryScale: CGFloat?, indicatorScale: CGFloat? = nil) {
        let images = attendees.compactMap { $0.metaImage(providers: nil, transparent: transparent, scale: primaryScale) }
        control.configure(items: images)
        
        if let attendee = attendees.first, attendee.isValid {
            switch attendee.senderType {
            case .`self`:
                break
                
            case .agent:
                guard let agent = attendee as? Agent else { return }

                if agent.onCall {
                    control.setActivity(agent.onCall ? .calling : nil, context: repicContext)
                }
                else {
                    control.setStatus(agent.state, worktimeEnabled: agent.isWorktimeEnabled, context: repicContext, scale: indicatorScale ?? 0.25)
                }

            case .client:
                guard let client = attendee as? Client else { return }
                
                if client.hasActiveCall {
                    control.setActivity(.calling, context: repicContext)
                }
                else if let task = client.task {
                    switch task.status {
                    case .active: control.setActivity(.taskActive, context: repicContext)
                    case .fired: control.setActivity(.taskFired, context: repicContext)
                    case .unknown: control.setActivity(nil, context: repicContext)
                    }
                }
                else {
                    control.setActivity(nil, context: repicContext)
                }
                
            case .guest:
                break
                
            case .teamchat:
                break
            }
        }
    }
    
    public func baseEmojiFont(scale: CGFloat?) -> UIFont {
        let fontSize = CGFloat(24 * (scale ?? 1))
        return DesignBook.shared.font(
            weight: .regular,
            category: .body,
            defaultSizes: DesignBookFontSize(compact: fontSize, regular: fontSize),
            maximumSizes: nil)
    }
    
//    func generateComplexAvatarView(height: CGFloat) -> AvatarView {
//        let config = JMRepicConfig(
//            interBorderWidth: 1,
//            interBorderColor: DesignBook.shared.color(usage: .primaryBackground),
//            outerBorderWidth: 0,
//            outerBorderColor: .clear,
//            totalHeight: height
//        )
//
//        return AvatarView(config: config)
//    }
    
    private func obtainColor(byHex hex: Int) -> UIColor {
        return UIColor(hex: hex)
    }
    
    private func obtainColor(forStyle style: DesignBookStyle, withAlias alias: DesignBookColorAlias) -> UIColor {
        switch style {
        case .light: return colors[style]?[alias] ?? .black
        case .dark: return colors[style]?[alias] ?? .white
        }
    }
    
    private func obtainColor(forUsage usage: DesignBookColorUsage) -> UIColor {
        switch usage {
        // global
        case .white: return UIColor.white
        case .black: return UIColor.black
        case .clear: return UIColor.clear
        // backgrounds
        case .statusBarBackground: return dynamicColor(light: .alias(.silverRegular), dark: .hex(0x151515))
        case .statusBarFailureBackground: return dynamicColor(light: .alias(.orangeRed), dark: .alias(.orangeRed))
        case .navigatorBackground: return dynamicColor(light: .alias(.white), dark: .hex(0x222222))
        case .statusHatBackground: return dynamicColor(light: .alias(.greenLight), dark: .alias(.greenLight))
        case .primaryBackground: return dynamicColor(light: .alias(.white), dark: .alias(.black))
        case .secondaryBackground: return dynamicColor(light: .hex(0xF2F2F7), dark: .hex(0x202020))
        case .slightBackground: return dynamicColor(light: .alias(.seashell), dark: .hex(0x1B1A1A))
        case .highlightBackground: return dynamicColor(light: .hex(0xCDE6FF), dark: .hex(0x3D566F))
        case .groupingBackground: return dynamicColor(light: .alias(.white), dark: .hex(0x1C1C1E))
        case .contentBackground: return dynamicColor(light: .alias(.grayLight), dark: .hex(0x202020))
        case .badgeBackground: return dynamicColor(light: .hex(0x808080), dark: .hex(0x808080))
        case .coveringBackground: return dynamicColor(light: .alias(.unknown1), dark: .hex(0x101010))
        case .darkBackground: return dynamicColor(light: .hex(0x1C1B17), dark: .hex(0x1C1B17))
        case .oppositeBackground: return dynamicColor(light: .alias(.black), dark: .alias(.white))
        case .attentiveLightBackground: return dynamicColor(light: .hex(0xEF9937), dark: .hex(0xEF9937))
        case .attentiveDarkBackground: return dynamicColor(light: .alias(.tangerine), dark: .alias(.tangerine))
        case .flashingBackground: return DesignBook.shared.color(usage: .warnTint).withAlpha(0.2)
        case .chattingBackground: return dynamicColor(light: .hex(0xF7F9FC), dark: .hex(0x101010))
        case .placeholderBackground: return dynamicColor(light: .hex(0xF1F1F2), dark: .hex(0x202020))
        // shadows
        case .dimmingShadow: return dynamicColor(light: .native(UIColor.black.withAlpha(0.56)), dark: .native(UIColor.white.withAlpha(0.25)))
        case .lightDimmingShadow: return dynamicColor(light: .native(UIColor.black.withAlpha(0.26)), dark: .native(UIColor.white.withAlpha(0.1)))
        case .focusingShadow: return dynamicColor(light: .hex(0x404040), dark: .alias(.white))
        // foregrounds
        case .statusHatForeground: return dynamicColor(light: .alias(.white), dark: .alias(.black))
        case .statusBarFailureForeground: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .primaryForeground: return dynamicColor(light: .alias(.black), dark: .alias(.white))
        case .secondaryForeground: return dynamicColor(light: .alias(.steel), dark: .alias(.steel))
        case .headingForeground: return dynamicColor(light: .alias(.brightBlue), dark: .hex(0x0080FF))
        case .highlightForeground: return dynamicColor(light: .alias(.brightBlue), dark: .native(.white))
        case .warningForeground: return dynamicColor(light: .alias(.orangeRed), dark: .alias(.orangeRed))
        case .identityDetectionForeground: return UIColor.dynamicLink ?? dynamicColor(light: .native(.black), dark: .alias(.white))
        case .linkDetectionForeground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        case .overpaintForeground: return dynamicColor(light: .alias(.grayLight), dark: .alias(.grayLight))
        case .oppositeForeground: return dynamicColor(light: .alias(.white), dark: .alias(.black))
        case .disabledForeground: return dynamicColor(light: .native(.lightGray), dark: .native(.darkGray))
        case .placeholderForeground: return dynamicColor(light: .hex(0xE1E1E2), dark: .hex(0x404040))
        // gradients
        case .informativeGradientTop: return dynamicColor(light: .hex(0x0C1A40), dark: .hex(0x202020))
        case .informativeGradientBottom: return dynamicColor(light: .hex(0x263959), dark: .hex(0x202020))
        // buttons
        case .primaryButtonBackground: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .primaryButtonForeground: return dynamicColor(light: .alias(.white), dark: .hex(0xE0E0E0))
        case .secondaryButtonBackground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        case .secondaryButtonForeground: return dynamicColor(light: .alias(.white), dark: .hex(0xE0E0E0))
        case .adaptiveButtonBackground: return dynamicColor(light: .alias(.white), dark: .hex(0x272729))
        case .adaptiveButtonForeground: return dynamicColor(light: .hex(0x767676), dark: .alias(.white))
        case .adaptiveButtonBorder: return dynamicColor(light: .alias(.black), dark: .native(.clear))
        case .saturatedButtonBackground: return dynamicColor(light: .hex(0x304CFB), dark: .hex(0x304CFB))
        case .saturatedButtonForeground: return dynamicColor(light: .alias(.white), dark: .hex(0xE0E0E0))
        case .dimmedButtonBackground: return dynamicColor(light: .alias(.grayDark), dark: .hex(0x505050))
        case .dimmedButtonForeground: return dynamicColor(light: .alias(.steel), dark: .hex(0xE0E0E0))
        case .triggerPrimaryButtonBackground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        case .triggerPrimaryButtonForeground: return dynamicColor(light: .alias(.white), dark: .hex(0xE0E0E0))
        case .triggerSecondaryButtonBackground: return dynamicColor(light: .hex(0xE1E1E2), dark: .alias(.white))
        case .triggerSecondaryButtonForeground: return dynamicColor(light: .hex(0x191919), dark: .hex(0x191919))
        case .actionButtonBackground: return dynamicColor(light: .alias(.white), dark: .alias(.black))
        case .actionActiveButtonForeground: return dynamicColor(light: .alias(.brightBlue), dark: .hex(0x0080FF))
        case .actionInactiveButtonForeground: return dynamicColor(light: .alias(.steel), dark: .alias(.steel))
        case .actionNeutralButtonForeground: return dynamicColor(light: .alias(.black), dark: .alias(.white))
        case .actionDangerButtonForeground: return dynamicColor(light: .alias(.orangeRed), dark: .hex(0xFF6B30))
        case .actionPressedButtonForeground: return dynamicColor(light: .alias(.black), dark: .alias(.white))
        case .actionDisabledButtonForeground: return dynamicColor(light: .alias(.steel), dark: .alias(.steel))
        case .destructiveBrightButtonBackground: return dynamicColor(light: .alias(.reddishPink), dark: .alias(.reddishPink))
        case .destructiveDimmedButtonBackground: return dynamicColor(light: .hex(0xFC4946), dark: .hex(0xDD0D35))
        case .destructiveButtonForeground: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .dialpadButtonForeground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        // separators
        case .primarySeparator: return dynamicColor(light: .alias(.silverLight), dark: .alias(.silverLight))
        case .secondarySeparator: return dynamicColor(light: .alias(.silverRegular), dark: .alias(.silverRegular))
        case .darkSeparator: return dynamicColor(light: .hex(0xD1D1D6), dark: .hex(0x737476))
        // controls
        case .navigatorTint: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.white))
        case .focusedTint: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .toggleOnTint: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .toggleOffTint: return dynamicColor(light: .alias(.grayLight), dark: .hex(0xA0A0A0))
        case .checkmarkOnBackground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.steel))
        case .checkmarkOffBackground: return dynamicColor(light: .alias(.grayDark), dark: .alias(.steel))
        case .attentiveTint: return dynamicColor(light: .alias(.orangeRed), dark: .alias(.orangeRed))
        case .performingTint: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .performedTint: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.white))
        case .accessoryTint: return dynamicColor(light: .alias(.steel), dark: .native(.gray))
        case .inactiveTint: return dynamicColor(light: .hex(0xD0D0D0), dark: .hex(0x404040))
        case .dialpadButtonTint: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        case .onlineTint: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .awayTint: return dynamicColor(light: .alias(.sunflowerYellow), dark: .alias(.sunflowerYellow))
        case .warnTint: return dynamicColor(light: .hex(0xFC4946), dark: .hex(0xFC4946))
        case .decorativeTint: return dynamicColor(light: .hex(0xEFEFF0), dark: .hex(0x1C1C1F))
        // indicators
        case .counterBackground: return dynamicColor(light: .alias(.brightBlue), dark: .alias(.brightBlue))
        case .counterForeground: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .activityCall: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .activityActiveTask: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .activityFiredTask: return dynamicColor(light: .alias(.reddishPink), dark: .alias(.reddishPink))
        // elements
        case .clientBackground: return dynamicColor(light: .alias(.greenJivo), dark: .alias(.greenJivo))
        case .clientForeground: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .clientLinkForeground: return dynamicColor(light: .hex(0x2222FF), dark: .hex(0x0000A0))
        case .clientIdentityForeground: return dynamicColor(light: .native(.white), dark: .alias(.white))
        case .clientTime: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .clientCheckmark: return dynamicColor(light: .alias(.white), dark: .alias(.white))
        case .agentBackground: return dynamicColor(light: .alias(.grayRegular), dark: .hex(0x333333))
        case .agentForeground: return dynamicColor(light: .alias(.black), dark: .alias(.white))
        case .agentLinkForeground: return obtainColor(forUsage: .linkDetectionForeground)
        case .agentIdentityForeground: return obtainColor(forUsage: .linkDetectionForeground)
        case .agentTime: return dynamicColor(light: .alias(.steel), dark: .alias(.steel))
        case .botButtonBackground: return dynamicColor(light: .hex(0xC0D0E0), dark: .hex(0x505050))
        case .botButtonForeground: return dynamicColor(light: .hex(0x202020), dark: .hex(0xD0D0D0))
        case .commentBackground: return dynamicColor(light: .hex(0xFEEAAC), dark: .hex(0x614800))
        case .callBorder: return dynamicColor(light: .alias(.grayDark), dark: .alias(.grayDark))
        case .failedBackground: return dynamicColor(light: .alias(.orangeRed), dark: .alias(.orangeRed))
        case .playingPassed: return dynamicColor(light: .alias(.unknown2), dark: .alias(.unknown2))
        case .playingAwaiting: return dynamicColor(light: .alias(.grayDark), dark: .alias(.grayDark))
        case .orderTint: return dynamicColor(light: .hex(0x8770DC), dark: .hex(0x8770DC))
        }
    }
    
    private func adjustedFontWeight(_ weight: DesignBookFontWeight) -> UIFont.Weight {
        if UIAccessibility.isBoldTextEnabled {
            switch weight {
            case .italics: return .regular
            case .light: return .regular
            case .regular: return .medium
            case .medium: return .semibold
            case .semibold: return .bold
            case .bold: return .heavy
            case .heavy: return .black
            }
        }
        else {
            switch weight {
            case .italics: return .regular
            case .light: return .light
            case .regular: return .regular;
            case .medium: return .medium;
            case .semibold: return .semibold;
            case .bold: return .bold
            case .heavy: return .heavy
            }
        }
    }
    
    private func extractFontSize(_ value: DesignBookFontSize) -> CGFloat {
        switch window.traitCollection.horizontalSizeClass {
        case .compact: return value.compact
        case .regular: return value.regular
        case .unspecified: return value.compact
        @unknown default: return value.compact
        }
    }
    
    private func dynamicColor(light lightColor: DesignBookColor, dark darkColor: DesignBookColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits in
                let style = traits.toDesignStyle
                let color: DesignBookColor = convert(style) { value in
                    switch value {
                    case .light: return lightColor
                    case .dark: return darkColor
                    }
                }
                
                return DesignBook.shared.color(color, style: style)
            }
        }
        else {
            switch usingForcedStyle ?? .light {
            case .light: return DesignBook.shared.color(lightColor, style: .light)
            case .dark: return DesignBook.shared.color(darkColor, style: .dark)
            }
        }
    }
}

extension UITraitCollection {
    public var toDesignStyle: DesignBookStyle {
        if #available(iOS 12.0, *) {
            switch userInterfaceStyle {
            case .light: return .light
            case .dark: return .dark
            case .unspecified: return .light
            @unknown default: return .light
            }
        }
        else {
            return .light
        }
    }
}
