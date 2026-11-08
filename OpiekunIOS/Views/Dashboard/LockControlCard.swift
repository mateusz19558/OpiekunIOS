import SwiftUI

public struct LockControlCard: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var showingCustomScheduleSheet: Bool = false

    public var body: some View {
        VStack(spacing: 16) {
            // Top Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("STAN KOMPUTERA")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textMuted)

                    Text(viewModel.status.isLocked ? "ZABLOKOWANY" : "ODBLOKOWANY")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(viewModel.status.isLocked ? AppColors.accentRed : AppColors.accentGreen)

                    Text(viewModel.status.lockReason)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.status.isLocked ? Color(hex: 0xfca5a5) : Color(hex: 0x86efac))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            (viewModel.status.isLocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.15)
                        )
                        .clipShape(Capsule())
                }

                Spacer()

                // Animated status icon
                ZStack {
                    Circle()
                        .fill((viewModel.status.isLocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.15))
                        .frame(width: 58, height: 58)

                    Image(systemName: viewModel.status.isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 28))
                        .foregroundColor(viewModel.status.isLocked ? AppColors.accentRed : AppColors.accentGreen)
                }
            }

            // Big Toggle Button
            Button {
                Task {
                    await viewModel.toggleLock()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: viewModel.status.isLocked ? "lock.open" : "lock.fill")
                    Text(viewModel.status.isLocked ? "Odblokuj komputer" : "Zablokuj komputer teraz")
                }
            }
            .buttonStyle(GlowingButtonStyle(
                gradient: viewModel.status.isLocked ? AppColors.unlockGradient : AppColors.lockGradient
            ))

            // Scheduled Lock Section
            VStack(alignment: .leading, spacing: 10) {
                Divider().background(AppColors.cardBorder)

                if viewModel.status.hasScheduledLock {
                    // Active scheduled lock card
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("⏳")
                                Text("ZAPLANOWANO BLOKADĘ")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(AppColors.accentAmber)
                            }
                            Text("Blokada za: \(Int(viewModel.status.scheduledLockRemainingMinutes)) min")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: 0xfef3c7))
                        }

                        Spacer()

                        Button {
                            Task {
                                await viewModel.cancelScheduledLock()
                            }
                        } label: {
                            Text("Anuluj ❌")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: 0xfca5a5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColors.accentRed.opacity(0.2))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppColors.accentRed.opacity(0.4), lineWidth: 1))
                        }
                    }
                    .padding(12)
                    .background(AppColors.accentAmber.opacity(0.12))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.accentAmber.opacity(0.35), lineWidth: 1))
                } else {
                    // Inactive quick scheduled lock buttons
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textMuted)
                            Text("Zaplanuj blokadę za określony czas:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)
                                .textCase(.uppercase)
                        }

                        HStack(spacing: 6) {
                            quickScheduleButton(5)
                            quickScheduleButton(10)
                            quickScheduleButton(15, isHighlighted: true)
                            quickScheduleButton(30)

                            Button {
                                showingCustomScheduleSheet = true
                            } label: {
                                Text("Inny...")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(AppColors.cardBackgroundSecondary)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
        }
        .modernCard()
        .sheet(isPresented: $showingCustomScheduleSheet) {
            ScheduledLockSheet(viewModel: viewModel)
        }
    }

    private func quickScheduleButton(_ minutes: Int, isHighlighted: Bool = false) -> some View {
        Button {
            Task {
                await viewModel.scheduleLock(minutes: minutes)
            }
        } label: {
            Text("\(minutes)m")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isHighlighted ? AppColors.accentAmber : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isHighlighted ? AppColors.accentAmber.opacity(0.15) : AppColors.cardBackgroundSecondary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHighlighted ? AppColors.accentAmber.opacity(0.5) : AppColors.cardBorder, lineWidth: 1)
                )
        }
    }
}

