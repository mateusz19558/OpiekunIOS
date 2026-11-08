import SwiftUI

public struct RulesView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var selectedTab: Int = 0

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Segmented control
                        Picker("Kategoria", selection: $selectedTab) {
                            Text("Aplikacje i Gry").tag(0)
                            Text("Strony WWW").tag(1)
                            Text("System Windows").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 4)

                        if selectedTab == 0 {
                            BlockedAppsView(viewModel: viewModel)
                        } else if selectedTab == 1 {
                            BlockedWebsitesView(viewModel: viewModel)
                        } else {
                            systemRulesView()
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Reguły i Ograniczenia")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func systemRulesView() -> some View {
        VStack(spacing: 14) {
            Toggle(isOn: Binding(
                get: { viewModel.status.blockWindowsSettings },
                set: { _ in Task { await viewModel.toggleWindowsSettings() } }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blokuj Ustawienia Windows i Panel Sterowania")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Uniemożliwia zmianę haseł, odinstalowywanie programów i zmianę konfiguracji")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .tint(AppColors.accentAmber)
            .modernCard()

            Toggle(isOn: Binding(
                get: { viewModel.status.blockSystemTools },
                set: { _ in Task { await viewModel.toggleSystemTools() } }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blokuj Narzędzia Systemowe (CMD, Regedit, PowerShell)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Chroni przed próbami zaawansowanego obejścia blokad przez wiersz poleceń lub rejestr")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .tint(AppColors.accentRed)
            .modernCard()

            Toggle(isOn: Binding(
                get: { viewModel.status.isInternetBlocked },
                set: { _ in Task { await viewModel.toggleInternet() } }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Całkowite odcięcie Internetu (Firewall)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Reguła systemowa blokuje dziecku wszelki ruch sieciowy zachowując połączenie z panelem rodzica")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .tint(AppColors.accentRed)
            .modernCard()
        }
    }
}

