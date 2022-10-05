//  
//  JVWorktime+Access.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public struct WorktimePointPair {
    public var since: WorktimePoint
    public var till: WorktimePoint
    
    public init(since: WorktimePoint, till: WorktimePoint) {
        self.since = since
        self.till = till
    }
}

public struct WorktimePoint: Comparable {
    public let hours: Int
    public let minutes: Int
    
    public init(hours: Int, minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
    
    public func calculateSeconds() -> Int {
        return (hours * 60 + minutes) * 60
    }
    
    public static func <(lhs: WorktimePoint, rhs: WorktimePoint) -> Bool {
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

public enum WorktimeDay: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    public static var today: WorktimeDay {
        let component = locale().calendar.component(.weekday, from: Date())
        return WorktimeDay.fromIndex(component - 1)
    }
    
    public static func fromIndex(_ index: Int) -> WorktimeDay {
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

public struct WorktimeDayConfig: Equatable {
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
        let sinceMins = staticTimeFormatter.format(startMinute)
        let tillMins = staticTimeFormatter.format(endMinute)
        return "\(startHour):\(sinceMins) - \(endHour):\(tillMins)"
    }
    
    public var date: Date {
        let baseDate = Date()
        return locale().calendar.date(
            bySettingHour: endHour,
            minute: endMinute,
            second: 0,
            of: baseDate) ?? baseDate
    }
}

public struct WorktimeDayMeta: Equatable {
    public let day: WorktimeDay
    public let config: WorktimeDayConfig
}

public struct WorktimeDayMetaPair: Equatable {
    public let today: WorktimeDayMeta?
    public let anotherDay: WorktimeDayMeta?
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
    
    public var todayConfig: WorktimeDayConfig? {
        return unpackLocalConfig(day: .today)
    }
    
    public var nextMetaPair: WorktimeDayMetaPair {
        return WorktimeDayMetaPair(
            today: obtainNextDayMeta(includingToday: true),
            anotherDay: obtainNextDayMeta(includingToday: false)
        )
    }
    
    public var activeDays: Set<String> {
        let days = WorktimeDay.allCases
        let configs = days.map(unpackLocalConfig)
        let activePairs = zip(days, configs).filter { day, config in config.enabled }
        return Set(activePairs.map { day, config in day.rawValue })
    }
    
    public func ifEnabled() -> JVWorktime? {
        return isEnabled ? self : nil
    }
    
    public func obtainNextDayMeta(includingToday: Bool) -> WorktimeDayMeta? {
        let originalSet = WorktimeDay.allCases + WorktimeDay.allCases
        guard let dayIndex = originalSet.firstIndex(of: .today) else { return nil }
        
        let offset = includingToday ? 0 : 1
        let valuableSet = originalSet.dropFirst(dayIndex + offset)
        
        for day in valuableSet {
            let config = unpackLocalConfig(day: day)
            if config.enabled {
                return WorktimeDayMeta(day: day, config: config)
            }
        }
        
        return nil
    }
    
    public func unpackLocalConfig(day: WorktimeDay) -> WorktimeDayConfig {
        let source: Int64 = convert(day) { day in
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
        
        return WorktimeDayConfig(
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
