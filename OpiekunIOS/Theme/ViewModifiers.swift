import SwiftUI

// MARK: - Glassmorphic / Cyber Card Modifier
struct ModernCardModifier: ViewModifier {
    var backgroundColor: Color = AppColors.cardBackground
    var borderColor: Color = AppColors.cardBorder
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: shadowRadius, x: 0, y: 4)
    }
}

// MARK: - Pill Badge Modifier
struct StatusPillModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.35), lineWidth: 1)
            )
    }
}

// MARK: - Glowing Button Style
struct GlowingButtonStyle: ButtonStyle {
    var gradient: LinearGradient
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                gradient
                    .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.2 : 0.45), radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    func modernCard(
        backgroundColor: Color = AppColors.cardBackground,
        borderColor: Color = AppColors.cardBorder,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.modifier(ModernCardModifier(backgroundColor: backgroundColor, borderColor: borderColor, cornerRadius: cornerRadius))
    }

    func statusPill(color: Color) -> some View {
        self.modifier(StatusPillModifier(color: color))
    }
}

