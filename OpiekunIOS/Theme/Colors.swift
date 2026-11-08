import SwiftUI

// MARK: - App Color Palette & Theme
public enum AppColors {
    // Backgrounds
    public static let background = Color(hex: 0x0a0e17)
    public static let secondaryBackground = Color(hex: 0x0f172a)
    public static let cardBackground = Color(hex: 0x131b2e)
    public static let cardBackgroundSecondary = Color(hex: 0x1a243b)
    public static let cardBorder = Color(hex: 0x22304d)
    public static let inputBackground = Color(hex: 0x162035)

    // Accents
    public static let accentBlue = Color(hex: 0x38bdf8)
    public static let accentRed = Color(hex: 0xef4444)
    public static let accentGreen = Color(hex: 0x10b981)
    public static let accentAmber = Color(hex: 0xf59e0b)
    public static let accentPurple = Color(hex: 0xa855f7)
    public static let accentCyan = Color(hex: 0x06b6d4)

    // Text
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: 0x94a3b8)
    public static let textMuted = Color(hex: 0x64748b)

    // Gradients
    public static let lockGradient = LinearGradient(
        colors: [Color(hex: 0xd97706), Color(hex: 0xdc2626)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let unlockGradient = LinearGradient(
        colors: [Color(hex: 0x059669), Color(hex: 0x0284c7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let blueGradient = LinearGradient(
        colors: [Color(hex: 0x0284c7), Color(hex: 0x38bdf8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xff) / 255.0
        let green = Double((hex >> 8) & 0xff) / 255.0
        let blue = Double(hex & 0xff) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    init(hexString: String) {
        var cleanString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanString.hasPrefix("#") {
            cleanString.remove(at: cleanString.startIndex)
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cleanString).scanHexInt64(&rgbValue)
        self.init(hex: UInt(rgbValue))
    }
}

