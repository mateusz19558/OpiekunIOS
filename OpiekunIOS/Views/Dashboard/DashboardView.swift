import SwiftUI

public struct DashboardView: View {
    @ObservedObject var viewModel: GuardianViewModel

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Top Status Bar (PC Name, User, Pulse Indicator)
                        HStack(alignment: .center) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke((viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed).opacity(0.4), lineWidth: 3)
                                            .scaleEffect(viewModel.isConnected ? 1.4 : 1.0)
                                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: viewModel.isConnected)
                                    )

                                Text(viewModel.isConnected ? "POŁĄCZONO NA ŻYWO" : "BRAK POŁĄCZENIA")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed)
                            }

                            Spacer()

                            // Connection Mode Switcher (Wi-Fi Dom / LTE Zdalnie)
                            Menu {
                                ForEach(ConnectionMode.allCases, id: \.self) { m in
                                    Button {
                                        viewModel.switchConnectionMode(m)
                                    } label: {
                                        HStack {
                                            Text(m.rawValue)
                                            if viewModel.profile.mode == m {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: viewModel.profile.isCurrentlyUsingRemote ? "globe" : "house.fill")
                                        .font(.system(size: 11))
                                    Text(viewModel.profile.isCurrentlyUsingRemote ? "Poza domem" : "Dom (Wi-Fi)")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(viewModel.profile.isCurrentlyUsingRemote ? AppColors.accentCyan : AppColors.accentBlue)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(AppColors.cardBackground)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                            }

                            // Active Windows user badge
                            HStack(spacing: 4) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 12))
                                Text(viewModel.status.currentActiveUser.isEmpty ? "Wszyscy" : viewModel.status.currentActiveUser)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                        }
                        .padding(.horizontal, 4)

                        // Sleep / Login Screen notification banner
                        if viewModel.status.isDesktopLockedOrSleeping == true {
                            HStack(spacing: 8) {
                                Text("💤")
                                    .font(.system(size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("KOMPUTER UŚPIONY LUB EKRAN LOGOWANIA")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(AppColors.accentBlue)
                                    Text("Czas dziecka jest wstrzymany. Odliczanie ruszy dopiero po zalogowaniu na pulpit.")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(Color(hex: 0x1e3a8a).opacity(0.35))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.accentBlue.opacity(0.4), lineWidth: 1))
                        }

                        // Pending Time Requests Banners
                        ForEach(viewModel.status.pendingTimeRequests.filter { $0.isPending }) { req in
                            TimeRequestAlertBanner(viewModel: viewModel, request: req)
                        }

                        // Master Lock Card
                        LockControlCard(viewModel: viewModel)

                        // Activity Gauge & Time Usage Card
                        TimeUsageRingCard(viewModel: viewModel)

                        // Quick Actions Grid (Firewall, Websites, Apps, Settings)
                        QuickActionGrid(viewModel: viewModel)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await viewModel.refreshStatus()
                }

                // Toast Notification Overlay
                if let toast = viewModel.toastMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.accentGreen)
                            Text(toast)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.cardBackgroundSecondary)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 5)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.toastMessage)
                }
            }
            .navigationTitle("Pulpit Opiekuna")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Text("🛡️")
                        Text(viewModel.profile.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticService.shared.selection()
                        Task { await viewModel.refreshStatus() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
            }
        }
    }
}

