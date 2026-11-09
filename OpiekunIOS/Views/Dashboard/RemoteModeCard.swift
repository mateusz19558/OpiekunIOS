import SwiftUI

public struct RemoteModeCard: View {
    @ObservedObject var viewModel: GuardianViewModel

    private var isRemoteActive: Bool {
        viewModel.status.isRemoteModeActive ?? false
    }

    private var isInputBlocked: Bool {
        viewModel.status.blockRemoteInput ?? false
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isRemoteActive ? AppColors.accentCyan.opacity(0.18) : AppColors.cardBackgroundSecondary)
                            .frame(width: 42, height: 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isRemoteActive ? AppColors.accentCyan.opacity(0.6) : AppColors.cardBorder, lineWidth: 1)
                            )

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TRYB ZDALNY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textPrimary)

                        Text("Szara tapeta i znak wodny na PC")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textMuted)
                    }
                }

                Spacer()

                // Active badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                        .frame(width: 6, height: 6)
                    Text(isRemoteActive ? "AKTYWNY" : "WYŁĄCZONY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(isRemoteActive ? AppColors.accentCyan.opacity(0.12) : AppColors.cardBackgroundSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isRemoteActive ? AppColors.accentCyan.opacity(0.4) : AppColors.cardBorder, lineWidth: 1)
                )
            }

            // Main Toggle Button
            Button {
                Task {
                    await viewModel.toggleRemoteMode()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isRemoteActive ? "stop.circle.fill" : "play.circle.fill")
                    Text(isRemoteActive ? "Zakończ tryb zdalny" : "Uruchom tryb zdalny")
                }
            }
            .buttonStyle(GlowingButtonStyle(
                gradient: isRemoteActive
                    ? LinearGradient(colors: [Color(hex: 0xb91c1c), Color(hex: 0xef4444)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(hex: 0x0284c7), Color(hex: 0x38bdf8)], startPoint: .leading, endPoint: .trailing)
            ))

            // Sub-control: Block Mouse and Keyboard slider / toggle (Only during Remote Mode)
            if isRemoteActive {
                VStack(spacing: 10) {
                    Divider().background(AppColors.cardBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Image(systemName: isInputBlocked ? "keyboard.badge.ellipsis" : "keyboard")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isInputBlocked ? AppColors.accentRed : AppColors.accentCyan)

                                    Text("Blokada myszy i klawiatury")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Text("Dziecko nie może ruszać kursorem ani pisać")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            Spacer()

                            // Interactive Toggle Switch
                            Toggle("", isOn: Binding(
                                get: { isInputBlocked },
                                set: { val in
                                    Task {
                                        await viewModel.setRemoteInputBlocked(val)
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(AppColors.accentRed)
                        }

                        // Status pill for input lock
                        HStack(spacing: 6) {
                            Image(systemName: isInputBlocked ? "lock.fill" : "lock.open.fill")
                                .font(.system(size: 11))
                            Text(isInputBlocked ? "Klawiatura i mysz są ZABLOKOWANE" : "Sterowanie dziecka jest DOZWOLONE")
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(isInputBlocked ? Color(hex: 0xfca5a5) : Color(hex: 0x86efac))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            (isInputBlocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.12)
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke((isInputBlocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .modernCard()
        .animation(.easeInOut(duration: 0.25), value: isRemoteActive)
        .animation(.easeInOut(duration: 0.2), value: isInputBlocked)
    }
}
