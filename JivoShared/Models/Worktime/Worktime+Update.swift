//  
//  Worktime+Update.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05.09.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JMCodingKit
import JMShared

extension Worktime {
    public func performApply(inside context: IDatabaseContext, with change: BaseModelChange) {
        if let c = change as? WorktimeBaseChange, _agentID == 0 {
            _agentID = c.agentID
        }
        
        if let c = change as? WorktimeGeneralChange {
            if _agentID == 0 { _agentID = c.agentID }
            
            _timezoneID = c.timezoneID
            _timezone = context.object(Timezone.self, primaryKey: _timezoneID)
            
            if !_isDirty {
                _enabled = c.enabled
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.monEnabled, start: c.monStart, end: c.monEnd),
                    forDay: .monday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.tueEnabled, start: c.tueStart, end: c.tueEnd),
                    forDay: .tuesday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.wedEnabled, start: c.wedStart, end: c.wedEnd),
                    forDay: .wednesday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.thuEnabled, start: c.thuStart, end: c.thuEnd),
                    forDay: .thursday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.friEnabled, start: c.friStart, end: c.friEnd),
                    forDay: .friday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.satEnabled, start: c.satStart, end: c.satEnd),
                    forDay: .saturday
                )
                
                storeLocalConfig(
                    unpackRemoteConfig(enabled: c.sunEnabled, start: c.sunStart, end: c.sunEnd),
                    forDay: .sunday
                )
            }
            
            _lastUpdate = Date()
        }
        else if let c = change as? WorktimeTimezoneChange {
            _timezoneID = c.timezoneID ?? _timezoneID
            _timezone = context.object(Timezone.self, primaryKey: _timezoneID)
        }
        else if let c = change as? WorktimeToggleChange {
            _enabled = c.enable
            _isDirty = true
        }
        else if let c = change as? WorktimeDayChange {
            storeLocalConfig(c.config, forDay: c.day)
            _isDirty = true
        }
        else if let c = change as? WorktimeDirtyChange {
            _isDirty = c.isDirty
        }
    }
    
    private func unpackRemoteConfig(enabled: Bool, start: String, end: String) -> WorktimeDayConfig {
        let sinceTime = extractTime(start)
        let tillTime = extractTime(end)

        return WorktimeDayConfig(
            enabled: enabled,
            startHour: sinceTime.hour,
            startMinute: sinceTime.minute,
            endHour: tillTime.hour,
            endMinute: tillTime.minute
        )
    }
    
    private func extractTime(_ time: String) -> (hour: Int, minute: Int) {
        let parts = time.split(separator: ":")
        guard parts.count == 2 else { return (0, 0) }
        guard let hourSource = parts.first, let hour = Int(hourSource) else { return (0, 0) }
        guard let minuteSource = parts.last, let minute = Int(minuteSource) else { return (0, 0) }
        return (hour, minute)
    }
    
    private func storeLocalConfig(_ config: WorktimeDayConfig, forDay day: WorktimeDay) {
        let sinceHourArg, sinceMinuteArg, tillHourArg, tillMinuteArg: Int64
        if config.startHour + config.startMinute + config.endHour + config.endMinute > 0 {
            sinceHourArg = Int64(config.startHour << 24)
            sinceMinuteArg = Int64(config.startMinute << 16)
            tillHourArg = Int64(config.endHour << 8)
            tillMinuteArg = Int64(config.endMinute << 0)
        }
        else {
            sinceHourArg = Int64(09 << 24)
            sinceMinuteArg = Int64(00 << 16)
            tillHourArg = Int64(18 << 8)
            tillMinuteArg = Int64(00 << 0)
        }
        
        let enabledArg = Int64(Int(config.enabled ? 1 : 0) << 32)
        let source = Int64(enabledArg | sinceHourArg | sinceMinuteArg | tillHourArg | tillMinuteArg)

        switch day {
        case .monday: _monConfig = source
        case .tuesday: _tueConfig = source
        case .wednesday: _wedConfig = source
        case .thursday: _thuConfig = source
        case .friday: _friConfig = source
        case .saturday: _satConfig = source
        case .sunday: _sunConfig = source
        }
    }
}
open class WorktimeBaseChange: BaseModelChange {
    public var agentID: Int
        public init(agentID: Int) {
        self.agentID = agentID
        super.init()
    }
    
    required public init(json: JsonElement) {
        agentID = json["agent_id"].intValue
        super.init(json: json)
    }
}

public final class WorktimeGeneralChange: BaseModelChange, Codable {
    public var agentID: Int
    public var timezoneID: Int
    public var enabled: Bool
    public var monEnabled: Bool
    public var monStart: String
    public var monEnd: String
    public var tueEnabled: Bool
    public var tueStart: String
    public var tueEnd: String
    public var wedEnabled: Bool
    public var wedStart: String
    public var wedEnd: String
    public var thuEnabled: Bool
    public var thuStart: String
    public var thuEnd: String
    public var friEnabled: Bool
    public var friStart: String
    public var friEnd: String
    public var satEnabled: Bool
    public var satStart: String
    public var satEnd: String
    public var sunEnabled: Bool
    public var sunStart: String
    public var sunEnd: String

    public override var primaryValue: Int {
        return agentID
    }
    
    public override var isValid: Bool {
        guard agentID > 0 else { return false }
        return true
    }
    
    required public init( json: JsonElement) {
        agentID = json["agent_id"].intValue
        timezoneID = json["timezone_id"].intValue
        enabled = json["work_time_enabled"].boolValue
        monEnabled = json["work_time"]["monday"].boolValue
        monStart = json["work_time"]["monday_start"].stringValue
        monEnd = json["work_time"]["monday_end"].stringValue
        tueEnabled = json["work_time"]["tuesday"].boolValue
        tueStart = json["work_time"]["tuesday_start"].stringValue
        tueEnd = json["work_time"]["tuesday_end"].stringValue
        wedEnabled = json["work_time"]["wednesday"].boolValue
        wedStart = json["work_time"]["wednesday_start"].stringValue
        wedEnd = json["work_time"]["wednesday_end"].stringValue
        thuEnabled = json["work_time"]["thursday"].boolValue
        thuStart = json["work_time"]["thursday_start"].stringValue
        thuEnd = json["work_time"]["thursday_end"].stringValue
        friEnabled = json["work_time"]["friday"].boolValue
        friStart = json["work_time"]["friday_start"].stringValue
        friEnd = json["work_time"]["friday_end"].stringValue
        satEnabled = json["work_time"]["saturday"].boolValue
        satStart = json["work_time"]["saturday_start"].stringValue
        satEnd = json["work_time"]["saturday_end"].stringValue
        sunEnabled = json["work_time"]["sunday"].boolValue
        sunStart = json["work_time"]["sunday_start"].stringValue
        sunEnd = json["work_time"]["sunday_end"].stringValue
        super.init(json: json)
    }
}

public final class WorktimeTimezoneChange: WorktimeBaseChange {
    public let timezoneID: Int?

    public override var primaryValue: Int {
        return agentID
    }
        public init(agentID: Int, timezoneID: Int?) {
        self.timezoneID = timezoneID
        super.init(agentID: agentID)
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}

public final class WorktimeToggleChange: WorktimeBaseChange {
    public let enable: Bool

    public override var primaryValue: Int {
        return agentID
    }
        public init(agentID: Int, enable: Bool) {
        self.enable = enable
        super.init(agentID: agentID)
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}

public final class WorktimeDayChange: WorktimeBaseChange {
    public let day: WorktimeDay
    public let config: WorktimeDayConfig
    
    public override var primaryValue: Int {
        return agentID
    }
        public init(agentID: Int, day: WorktimeDay, config: WorktimeDayConfig) {
        self.day = day
        self.config = config
        super.init(agentID: agentID)
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}

public final class WorktimeDirtyChange: WorktimeBaseChange {
    public let isDirty: Bool

    public override var primaryValue: Int {
        return agentID
    }
        public init(agentID: Int, isDirty: Bool) {
        self.isDirty = isDirty
        super.init(agentID: agentID)
    }
    
    required public init( json: JsonElement) {
        abort()
    }
}
