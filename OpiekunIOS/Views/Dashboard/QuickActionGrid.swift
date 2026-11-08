import SwiftUI

public struct QuickActionGrid: View {
    @ObservedObject var viewModel: GuardianViewModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SZYBKIE PRZEŁĄCZNIKI KONTROLNE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textMuted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Internet Killswitch
                actionTile(
                    title: "Dostęp do sieci",
                    value: viewModel.status.isInternetBlocked ? "ODCIĘTY" : "WŁĄCZONY",
                    subtitle: viewModel.status.isInternetBlocked ? "Internet zablokowany" : "Dziecko ma sieć",
                    iconName: "globe",
                    isActive: !viewModel.status.isInternetBlocked,
                    activeColor: AppColors.accentGreen,
                    inactiveColor: AppColors.accentRed
                ) {
                    Task { await viewModel.toggleInternet() }
                }

                // Website Filter
                actionTile(
                    title: "Blokada stron www",
                    value: viewModel.status.blockedWebsitesEnabled ? "AKTYWNA" : "WYŁĄCZONA",
                    subtitle: "\(viewModel.status.blockedDomainsCount) zablokowanych domen",
                    iconName: "shield.slash.fill",
                    isActive: viewModel.status.blockedWebsitesEnabled,
                    activeColor: AppColors.accentPurple,
                    inactiveColor: AppColors.textMuted
                ) {
                    Task { await viewModel.toggleWebsitesBlock() }
                }

                // Blocked Apps & Games
                actionTile(
                    title: "Blokada gier/apek",
                    value: viewModel.status.blockedApplicationsEnabled ? "AKTYWNA" : "WYŁĄCZONA",
                    subtitle: "\(viewModel.status.blockedApplications.count) procesów na liście",
                    iconName: "gamecontroller.fill",
                    isActive: viewModel.status.blockedApplicationsEnabled,
                    activeColor: AppColors.accentRed,
                    inactiveColor: AppColors.textMuted
                ) {
                    Task { await viewModel.toggleBlockedApps() }
                }

                // Windows Settings & Control Panel
                actionTile(
                    title: "Ustawienia Windows",
                    value: viewModel.status.blockWindowsSettings ? "ZABLOKOWANE" : "DOSTĘPNE",
                    subtitle: viewModel.status.blockWindowsSettings ? "Dziecko nie zmieni opcji" : "Brak blokady",
                    iconName: "gearshape.fill",
                    isActive: viewModel.status.blockWindowsSettings,
                    activeColor: AppColors.accentAmber,
                    inactiveColor: AppColors.textMuted
                ) {
                    Task { await viewModel.toggleWindowsSettings() }
                }

                // Advanced System Tools (CMD, Regedit, PS)
                actionTile(
                    title: "Narzędzia systemowe",
                    value: viewModel.status.blockSystemTools ? "ZABLOKOWANE" : "DOSTĘPNE",
                    subtitle: "CMD, Rejestr, PowerShell",
                    iconName: "terminal.fill",
                    isActive: viewModel.status.blockSystemTools,
                    activeColor: AppColors.accentRed,
                    inactiveColor: AppColors.textMuted
                ) {
                    Task { await viewModel.toggleSystemTools() }
                }

                // Schedule Enforced
                actionTile(
                    title: "Harmonogram",
                    value: viewModel.status.scheduleEnabled ? "AKTYWNY" : "WYŁĄCZONY",
                    subtitle: viewModel.status.isInsideAllowedHours ? "Dozwolone godziny" : "Poza godzinami",
                    iconName: "calendar.badge.clock",
                    isActive: viewModel.status.scheduleEnabled,
                    activeColor: AppColors.accentBlue,
                    inactiveColor: AppColors.textMuted
                ) {
                    // Navigate to Schedule
                }
            }
        }
    }

    private func actionTile(
        title: String,
        value: String,
        subtitle: String,
        iconName: String,
        isActive: Bool,
        activeColor: Color,
        inactiveColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill((isActive ? activeColor : inactiveColor).opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: iconName)
                            .font(.system(size: 14))
                            .foregroundColor(isActive ? activeColor : inactiveColor)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(isActive ? activeColor : .white)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textMuted)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(AppColors.cardBackground)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

