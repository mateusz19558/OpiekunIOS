import Foundation

public struct DaySchedule: Codable, Equatable {
    public var enabled: Bool
    public var startTime: String // HH:mm
    public var endTime: String   // HH:mm
    public var maxMinutes: Int

    public init(enabled: Bool = true, startTime: String = "14:00", endTime: String = "20:00", maxMinutes: Int = 120) {
        self.enabled = enabled
        self.startTime = startTime
        self.endTime = endTime
        self.maxMinutes = maxMinutes
    }
}

public struct AppSettings: Codable, Equatable {
    public var parentPin: String
    public var port: Int
    public var targetUserMode: String // "Specific" or "All"
    public var targetUserName: String
    public var isManualLocked: Bool
    public var manualUnlockOverride: Bool
    public var scheduledLockTime: String?
    public var blockWindowsSettings: Bool
    public var blockSystemTools: Bool
    public var blockedApplicationsEnabled: Bool
    public var blockedApplications: [String]
    public var isInternetBlocked: Bool
    public var blockedWebsitesEnabled: Bool
    public var blockedDomains: [String]
    public var scheduleEnabled: Bool
    public var weeklySchedule: [String: DaySchedule]
    public var todayDate: String
    public var todayUsedMinutes: Double
    public var bonusMinutesToday: Double
    public var autoScreenshotIntervalMinutes: Int

    public init(
        parentPin: String = "1234",
        port: Int = 5050,
        targetUserMode: String = "Specific",
        targetUserName: String = "",
        isManualLocked: Bool = false,
        manualUnlockOverride: Bool = false,
        scheduledLockTime: String? = nil,
        blockWindowsSettings: Bool = false,
        blockSystemTools: Bool = false,
        blockedApplicationsEnabled: Bool = true,
        blockedApplications: [String] = ["robloxplayerbeta", "javaw", "steam", "epicgameslauncher", "discord"],
        isInternetBlocked: Bool = false,
        blockedWebsitesEnabled: Bool = true,
        blockedDomains: [String] = ["youtube.com", "tiktok.com", "roblox.com", "facebook.com", "discord.com"],
        scheduleEnabled: Bool = true,
        weeklySchedule: [String: DaySchedule] = Self.defaultSchedule(),
        todayDate: String = "",
        todayUsedMinutes: Double = 0,
        bonusMinutesToday: Double = 0,
        autoScreenshotIntervalMinutes: Int = 0
    ) {
        self.parentPin = parentPin
        self.port = port
        self.targetUserMode = targetUserMode
        self.targetUserName = targetUserName
        self.isManualLocked = isManualLocked
        self.manualUnlockOverride = manualUnlockOverride
        self.scheduledLockTime = scheduledLockTime
        self.blockWindowsSettings = blockWindowsSettings
        self.blockSystemTools = blockSystemTools
        self.blockedApplicationsEnabled = blockedApplicationsEnabled
        self.blockedApplications = blockedApplications
        self.isInternetBlocked = isInternetBlocked
        self.blockedWebsitesEnabled = blockedWebsitesEnabled
        self.blockedDomains = blockedDomains
        self.scheduleEnabled = scheduleEnabled
        self.weeklySchedule = weeklySchedule
        self.todayDate = todayDate
        self.todayUsedMinutes = todayUsedMinutes
        self.bonusMinutesToday = bonusMinutesToday
        self.autoScreenshotIntervalMinutes = autoScreenshotIntervalMinutes
    }

    public static func defaultSchedule() -> [String: DaySchedule] {
        return [
            "Monday": DaySchedule(enabled: true, startTime: "14:00", endTime: "20:00", maxMinutes: 120),
            "Tuesday": DaySchedule(enabled: true, startTime: "14:00", endTime: "20:00", maxMinutes: 120),
            "Wednesday": DaySchedule(enabled: true, startTime: "14:00", endTime: "20:00", maxMinutes: 120),
            "Thursday": DaySchedule(enabled: true, startTime: "14:00", endTime: "20:00", maxMinutes: 120),
            "Friday": DaySchedule(enabled: true, startTime: "14:00", endTime: "21:30", maxMinutes: 180),
            "Saturday": DaySchedule(enabled: true, startTime: "09:00", endTime: "21:30", maxMinutes: 240),
            "Sunday": DaySchedule(enabled: true, startTime: "09:00", endTime: "20:00", maxMinutes: 180)
        ]
    }
}

