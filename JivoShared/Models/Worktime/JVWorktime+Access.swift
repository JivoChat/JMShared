//  
//  JVWorktime+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public struct JVWorktimePointPair {
    public var since: JVWorktimePoint
    public var till: JVWorktimePoint
    
    public init(since: JVWorktimePoint, till: JVWorktimePoint) {
        self.since = since
        self.till = till
    }
}

public struct JVWorktimePoint: Comparable {
    public let hours: Int
    public let minutes: Int
    
    public init(hours: Int, minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
    
    public func calculateSeconds() -> Int {
        return (hours * 60 + minutes) * 60
    }
    
    public static func <(lhs: JVWorktimePoint, rhs: JVWorktimePoint) -> Bool {
        if lhs.hours < rhs.hours {
            return true
        }
        else if lhs.hours == rhs.hours, lhs.minutes < rhs.minutes {
            return true
        }
        else {
            return false
        }
    }
}

public enum JVWorktimeDay: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    public static var today: JVWorktimeDay {
        let component = JVActiveLocale().calendar.component(.weekday, from: Date())
        return JVWorktimeDay.fromIndex(component - 1)
    }
    
    public static func fromIndex(_ index: Int) -> JVWorktimeDay {
        switch index {
        case 0: return .sunday
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        default: return .monday
        }
    }
    
    public var systemIndex: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

public struct JVWorktimeDayConfig: Equatable {
    public var enabled: Bool
    public var startHour: Int
    public var startMinute: Int
    public var endHour: Int
    public var endMinute: Int
    
    public init(
        enabled: Bool,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int
    ) {
        self.enabled = enabled
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }
    
    public var timeDescription: String {
        let sinceMins = staticTimeFormatter.jv_format(startMinute)
        let tillMins = staticTimeFormatter.jv_format(endMinute)
        return "\(startHour):\(sinceMins) - \(endHour):\(tillMins)"
    }
    
    public var date: Date {
        let baseDate = Date()
        return JVActiveLocale().calendar.date(
            bySettingHour: endHour,
            minute: endMinute,
            second: 0,
            of: baseDate) ?? baseDate
    }
}

public struct JVWorktimeDayMeta: Equatable {
    public let day: JVWorktimeDay
    public let config: JVWorktimeDayConfig
}

public struct JVWorktimeDayMetaPair: Equatable {
    public let today: JVWorktimeDayMeta?
    public let anotherDay: JVWorktimeDayMeta?
}

extension JVWorktime {
    public var agentID: Int {
        return _agentID
    }
    
    public var timezoneID: Int? {
        if _timezoneID > 0 {
            return _timezoneID
        }
        else {
            return nil
        }
    }
    
    public var timezone: JVTimezone? {
        return _timezone
    }
    
    public var isEnabled: Bool {
        return _enabled
    }
    
    public var todayConfig: JVWorktimeDayConfig? {
        return unpackLocalConfig(day: .today)
    }
    
    public var nextMetaPair: JVWorktimeDayMetaPair {
        return JVWorktimeDayMetaPair(
            today: obtainNextDayMeta(includingToday: true),
            anotherDay: obtainNextDayMeta(includingToday: false)
        )
    }
    
    public var activeDays: Set<String> {
        let days = JVWorktimeDay.allCases
        let configs = days.map(unpackLocalConfig)
        let activePairs = zip(days, configs).filter { day, config in config.enabled }
        return Set(activePairs.map { day, config in day.rawValue })
    }
    
    public func ifEnabled() -> JVWorktime? {
        return isEnabled ? self : nil
    }
    
    public func obtainNextDayMeta(includingToday: Bool) -> JVWorktimeDayMeta? {
        let originalSet = JVWorktimeDay.allCases + JVWorktimeDay.allCases
        guard let dayIndex = originalSet.firstIndex(of: .today) else { return nil }
        
        let offset = includingToday ? 0 : 1
        let valuableSet = originalSet.dropFirst(dayIndex + offset)
        
        for day in valuableSet {
            let config = unpackLocalConfig(day: day)
            if config.enabled {
                return JVWorktimeDayMeta(day: day, config: config)
            }
        }
        
        return nil
    }
    
    public func unpackLocalConfig(day: JVWorktimeDay) -> JVWorktimeDayConfig {
        let source: Int64 = jv_convert(day) { day in
            switch day {
            case .monday: return _monConfig
            case .tuesday: return _tueConfig
            case .wednesday: return _wedConfig
            case .thursday: return _thuConfig
            case .friday: return _friConfig
            case .saturday: return _satConfig
            case .sunday: return _sunConfig
            }
        }
        
        return JVWorktimeDayConfig(
            enabled: ((source & 0xFF00000000) >> 32) > 0,
            startHour: Int((source & 0x00FF000000) >> 24),
            startMinute: Int((source & 0x0000FF0000) >> 16),
            endHour: Int((source & 0x000000FF00) >> 8),
            endMinute: Int((source & 0x00000000FF) >> 0)
        )
    }
}

fileprivate let staticTimeFormatter: NumberFormatter = {
    let result = NumberFormatter()
    result.minimumIntegerDigits = 2
    return result
}()
