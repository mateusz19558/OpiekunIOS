import SwiftUI

public struct RunningAppsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GuardianViewModel

    @State private var runningApps: [RunningApp] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack {
                    if isLoading {
                        ProgressView("Wykrywanie procesów na PC...")
                            .tint(AppColors.accentBlue)
                            .foregroundColor(AppColors.textSecondary)
                    } else if runningApps.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "desktopcomputer")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.textMuted)
                            Text("Brak uruchomionych aplikacji z oknami")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(runningApps) { app in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(app.windowTitle.isEmpty ? app.processName : app.windowTitle)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)

                                        Text("\(app.processName).exe")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(AppColors.accentBlue)
                                    }

                                    Spacer()

                                    let isAlreadyBlocked = viewModel.status.blockedApplications.contains {
                                        $0.caseInsensitiveCompare(app.processName) == .orderedSame
                                    }

                                    if isAlreadyBlocked {
                                        Text("Zablokowane ✓")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(AppColors.accentRed)
                                    } else {
                                        Button {
                                            blockApp(app.processName)
                                        } label: {
                                            Text("Zablokuj")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppColors.accentRed)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .listRowBackground(AppColors.cardBackground)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Uruchomione Programy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        loadRunningApps()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
            }
            .onAppear {
                loadRunningApps()
            }
        }
    }

    private func loadRunningApps() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let list = try await APIService.shared.getRunningApps(profile: viewModel.profile)
                self.runningApps = list
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func blockApp(_ name: String) {
        Task {
            do {
                try await APIService.shared.addBlockedApp(appName: name, profile: viewModel.profile)
                viewModel.status.blockedApplications.append(name.lowercased())
                HapticService.shared.notification(.success)
            } catch {
                HapticService.shared.notification(.error)
            }
        }
    }
}

