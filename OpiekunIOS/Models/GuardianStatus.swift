import Foundation

public struct GuardianStatus: Codable, Equatable {
    public var isLocked: Bool
    public var lockReason: String
    public var currentActiveUser: String
    public var targetUserName: String
    public var targetUserMode: String
    public var isTargetUserActive: Bool
    public var isInternetBlocked: Bool
    public var blockedWebsitesEnabled: Bool
    public var blockedDomainsCount: Int
    public var blockWindowsSettings: Bool
    public var blockSystemTools: Bool
    public var blockedApplicationsEnabled: Bool
    public var blockedApplications: [String]
    public var todayUsedMinutes: Double
    public var todayAllowedMinutes: Double
    public var remainingMinutes: Double
    public var scheduleEnabled: Bool
    public var allowedHoursText: String
    public var isInsideAllowedHours: Bool
    public var hasScheduledLock: Bool
    public var scheduledLockTime: String?
    public var scheduledLockRemainingMinutes: Double
    public var pendingTimeRequests: [TimeRequest]
    public var localIpAddresses: [String]
    public var serverPort: Int
    public var lastParentMessage: String
    public var lastScreenshotTime: String?

    public init(
        isLocked: Bool = false,
        lockReason: String = "Brak blokady",
        currentActiveUser: String = "",
        targetUserName: String = "",
        targetUserMode: String = "Specific",
        isTargetUserActive: Bool = false,
        isInternetBlocked: Bool = false,
        blockedWebsitesEnabled: Bool = false,
        blockedDomainsCount: Int = 0,
        blockWindowsSettings: Bool = false,
        blockSystemTools: Bool = false,
        blockedApplicationsEnabled: Bool = false,
        blockedApplications: [String] = [],
        todayUsedMinutes: Double = 0,
        todayAllowedMinutes: Double = 120,
        remainingMinutes: Double = 120,
        scheduleEnabled: Bool = true,
        allowedHoursText: String = "14:00 - 20:00",
        isInsideAllowedHours: Bool = true,
        hasScheduledLock: Bool = false,
        scheduledLockTime: String? = nil,
        scheduledLockRemainingMinutes: Double = 0,
        pendingTimeRequests: [TimeRequest] = [],
        localIpAddresses: [String] = [],
        serverPort: Int = 5050,
        lastParentMessage: String = "",
        lastScreenshotTime: String? = nil
    ) {
        self.isLocked = isLocked
        self.lockReason = lockReason
        self.currentActiveUser = currentActiveUser
        self.targetUserName = targetUserName
        self.targetUserMode = targetUserMode
        self.isTargetUserActive = isTargetUserActive
        self.isInternetBlocked = isInternetBlocked
        self.blockedWebsitesEnabled = blockedWebsitesEnabled
        self.blockedDomainsCount = blockedDomainsCount
        self.blockWindowsSettings = blockWindowsSettings
        self.blockSystemTools = blockSystemTools
        self.blockedApplicationsEnabled = blockedApplicationsEnabled
        self.blockedApplications = blockedApplications
        self.todayUsedMinutes = todayUsedMinutes
        self.todayAllowedMinutes = todayAllowedMinutes
        self.remainingMinutes = remainingMinutes
        self.scheduleEnabled = scheduleEnabled
        self.allowedHoursText = allowedHoursText
        self.isInsideAllowedHours = isInsideAllowedHours
        self.hasScheduledLock = hasScheduledLock
        self.scheduledLockTime = scheduledLockTime
        self.scheduledLockRemainingMinutes = scheduledLockRemainingMinutes
        self.pendingTimeRequests = pendingTimeRequests
        self.localIpAddresses = localIpAddresses
        self.serverPort = serverPort
        self.lastParentMessage = lastParentMessage
        self.lastScreenshotTime = lastScreenshotTime
    }

    // Helper calculated properties
    public var progressRatio: Double {
        guard todayAllowedMinutes > 0 else { return 0 }
        let ratio = todayUsedMinutes / todayAllowedMinutes
        return min(max(ratio, 0.0), 1.0)
    }

    public var formattedUsedTime: String {
        let mins = Int(todayUsedMinutes)
        if mins >= 60 {
            return "\(mins / 60)h \(mins % 60)m"
        }
        return "\(mins) min"
    }

    public var formattedRemainingTime: String {
        let mins = max(0, Int(remainingMinutes))
        if mins >= 60 {
            return "\(mins / 60)h \(mins % 60)m"
        }
        return "\(mins) min"
    }

    public var formattedLimitTime: String {
        let mins = Int(todayAllowedMinutes)
        if mins >= 60 {
            return "\(mins / 60)h \(mins % 60)m"
        }
        return "\(mins) min"
    }

    public var activeUserName: String {
        currentActiveUser.isEmpty ? "Nieznany" : currentActiveUser
    }
}

