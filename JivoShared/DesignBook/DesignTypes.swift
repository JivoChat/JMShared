//
//  DesignTypes.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
public enum DesignBookStyle {
    case light
    case dark
}
public enum DesignBookColor {
    case native(UIColor)
    case hex(Int)
    case alias(DesignBookColorAlias)
    case usage(DesignBookColorUsage)
}
public enum DesignBookColorAlias {
    case darkBackground
    case white
    case black
    case background
    case stillBackground
    case silverLight
    case silverRegular
    case steel
    case grayLight
    case grayRegular
    case grayDark
    case tangerine
    case sunflowerYellow
    case reddishPink
    case orangeRed
    case greenLight
    case greenJivo
    case skyBlue
    case brightBlue
    case darkPeriwinkle
    case seashell
    case alto
    case unknown1
    case unknown2
    case unknown3
    case unknown4
    case unknown5
    case color_ff2f0e
    case color_00bc31
}
public enum DesignBookColorUsage {
    // global
    case white
    case black
    case clear
    // backgrounds
    case statusBarBackground
    case statusBarFailureBackground
    case navigatorBackground
    case statusHatBackground
    case primaryBackground
    case secondaryBackground
    case slightBackground
    case highlightBackground
    case groupingBackground
    case contentBackground
    case badgeBackground
    case coveringBackground
    case darkBackground
    case oppositeBackground
    case attentiveLightBackground
    case attentiveDarkBackground
    case flashingBackground
    case chattingBackground
    case placeholderBackground
    // shadow
    case dimmingShadow
    case lightDimmingShadow
    case focusingShadow
    // foregrounds
    case statusHatForeground
    case statusBarFailureForeground
    case primaryForeground
    case secondaryForeground
    case headingForeground
    case highlightForeground
    case warningForeground
    case identityDetectionForeground
    case linkDetectionForeground
    case overpaintForeground
    case oppositeForeground
    case disabledForeground
    case placeholderForeground
    // gradients
    case informativeGradientTop
    case informativeGradientBottom
    // buttons
    case primaryButtonBackground
    case primaryButtonForeground
    case secondaryButtonBackground
    case secondaryButtonForeground
    case saturatedButtonBackground
    case saturatedButtonForeground
    case dimmedButtonBackground
    case dimmedButtonForeground
    case triggerRegularButtonBackground
    case triggerRegularButtonForeground
    case triggerContrastButtonBackground
    case triggerContrastButtonForeground
    case actionButtonBackground
    case actionPassiveButtonForeground
    case actionActiveButtonForeground
    case actionDangerButtonForeground
    case actionPressedButtonForeground
    case actionDisabledButtonForeground
    case destructiveBrightButtonBackground
    case destructiveDimmedButtonBackground
    case destructiveButtonForeground
    case dialpadButtonForeground
    // separators
    case primarySeparator
    case secondarySeparator
    case darkSeparator
    // controls
    case navigatorTint
    case focusedTint
    case toggleOnTint
    case toggleOffTint
    case checkmarkOnBackground
    case checkmarkOffBackground
    case attentiveTint
    case performingTint
    case performedTint
    case accessoryTint
    case inactiveTint
    case dialpadButtonTint
    case onlineTint
    case awayTint
    case warnTint
    case decorativeTint
    // indicators
    case counterBackground
    case counterForeground
    case activityCall
    case activityActiveReminder
    case activityFiredReminder
    // elements
    case clientBackground
    case clientForeground
    case clientLinkForeground
    case clientIdentityForeground
    case clientTime
    case clientCheckmark
    case agentBackground
    case agentForeground
    case agentLinkForeground
    case agentIdentityForeground
    case agentTime
    case commentBackground
    case botButtonBackground
    case botButtonForeground
    case callBorder
    case failedBackground
    case playingPassed
    case playingAwaiting
    case orderTint
}
public enum DesignBookFontWeight {
    case italics
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
}
public struct DesignBookFontSize {
    public let compact: CGFloat
    public let regular: CGFloat
    
    public init(compact: CGFloat, regular: CGFloat) {
        self.compact = compact
        self.regular = regular
    }
}
public struct DesignBookLayout {
    public let sideMargin: CGFloat
    public let controlMargin: CGFloat
    public let controlBigRadius: CGFloat
    public let controlSmallRadius: CGFloat
    public let alertRadius: CGFloat
    public let defaultMediaRatio: CGFloat
    
    public init(
        sideMargin: CGFloat,
        controlMargin: CGFloat,
        controlBigRadius: CGFloat,
        controlSmallRadius: CGFloat,
        alertRadius: CGFloat,
        defaultMediaRatio: CGFloat
    ) {
        self.sideMargin = sideMargin
        self.controlMargin = controlMargin
        self.controlBigRadius = controlBigRadius
        self.controlSmallRadius = controlSmallRadius
        self.alertRadius = alertRadius
        self.defaultMediaRatio = defaultMediaRatio
    }
}
public enum DesignBookScreenSize: Int, Comparable {
    case small
    case standard
    case large
    case extraLarge
    
    public static func < (lhs: DesignBookScreenSize, rhs: DesignBookScreenSize) -> Bool {
        guard lhs.rawValue < rhs.rawValue else { return false }
        return true
    }
}
