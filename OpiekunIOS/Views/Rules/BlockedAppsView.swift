import SwiftUI

public struct BlockedAppsView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var newAppName: String = ""
    @State private var showingRunningAppsSheet: Bool = false

    private let quickPresets = [
        ("Roblox", "robloxplayerbeta"),
        ("Minecraft", "javaw"),
        ("Steam", "steam"),
        ("Discord", "discord"),
        ("Epic Games", "epicgameslauncher"),
        ("Fortnite", "fortniteclient-win64-shipping"),
        ("Chrome", "chrome"),
        ("Opera", "opera"),
        ("TikTok", "tiktok live studio")
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Master toggle
            Toggle(isOn: Binding(
                get: { viewModel.status.blockedApplicationsEnabled },
                set: { _ in Task { await viewModel.toggleBlockedApps() } }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blokada wybranych aplikacji i gier")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Gdy włączona, wskazane gry nie będą mogły zostać uruchomione")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .tint(AppColors.accentRed)
            .modernCard()

            // Running Apps Button
            Button {
                showingRunningAppsSheet = true
            } label: {
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentBlue.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "desktopcomputer")
                            .foregroundColor(AppColors.accentBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sprawdź uruchomione aplikacje na PC")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Wybierz proces z listy aktywnych okien i zablokuj 1 kliknięciem")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.textMuted)
                }
                .modernCard()
            }

            // Quick Add Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("SZYBKIE BLOKOWANIE GIER")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textMuted)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickPresets, id: \.1) { preset in
                            let isBlocked = viewModel.status.blockedApplications.contains {
                                $0.caseInsensitiveCompare(preset.1) == .orderedSame
                            }

                            Button {
                                if !isBlocked {
                                    addApp(preset.1)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(isBlocked ? "✓" : "+")
                                    Text(preset.0)
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isBlocked ? AppColors.accentRed : .white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isBlocked ? AppColors.accentRed.opacity(0.15) : AppColors.cardBackground)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isBlocked ? AppColors.accentRed.opacity(0.5) : AppColors.cardBorder, lineWidth: 1))
                            }
                            .disabled(isBlocked)
                        }
                    }
                }
            }

            // Manual Add Input
            VStack(alignment: .leading, spacing: 8) {
                Text("DODAJ WŁASNY PROCES (.EXE)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textMuted)

                HStack(spacing: 8) {
                    TextField("np. roblox, javaw, csgo", text: $newAppName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Button {
                        if !newAppName.trimmingCharacters(in: .whitespaces).isEmpty {
                            addApp(newAppName.trimmingCharacters(in: .whitespaces))
                            newAppName = ""
                        }
                    } label: {
                        Text("+ Dodaj")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.accentBlue)
                            .cornerRadius(10)
                    }
                    .disabled(newAppName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            // Current Blocked Apps List
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("AKTUALNA CZARNA LISTA (\(viewModel.status.blockedApplications.count))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textMuted)

                    Spacer()

                    Text("Dotknij ❌ aby usunąć")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textMuted)
                }

                if viewModel.status.blockedApplications.isEmpty {
                    Text("Brak zablokowanych aplikacji")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.status.blockedApplications, id: \.self) { app in
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "slash.circle.fill")
                                        .foregroundColor(AppColors.accentRed)
                                    Text("\(app).exe")
                                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                Button {
                                    removeApp(app)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.accentRed.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingRunningAppsSheet) {
            RunningAppsSheet(viewModel: viewModel)
        }
    }

    private func addApp(_ name: String) {
        HapticService.shared.impact(.light)
        Task {
            do {
                try await APIService.shared.addBlockedApp(appName: name, profile: viewModel.profile)
                if !viewModel.status.blockedApplications.contains(name.lowercased()) {
                    viewModel.status.blockedApplications.append(name.lowercased())
                }
                viewModel.showToast("Zablokowano: \(name)")
            } catch {
                viewModel.showToast("Błąd dodawania blokady")
            }
        }
    }

    private func removeApp(_ name: String) {
        HapticService.shared.impact(.light)
        Task {
            do {
                try await APIService.shared.removeBlockedApp(appName: name, profile: viewModel.profile)
                viewModel.status.blockedApplications.removeAll { $0.caseInsensitiveCompare(name) == .orderedSame }
                viewModel.showToast("Odblokowano: \(name)")
            } catch {
                viewModel.showToast("Błąd usuwania blokady")
            }
        }
    }
}

