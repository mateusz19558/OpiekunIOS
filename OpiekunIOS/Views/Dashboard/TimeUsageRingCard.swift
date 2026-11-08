import SwiftUI

public struct TimeUsageRingCard: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var showingResetConfirmation = false

    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Text("⏱️")
                    Text("Wykorzystanie czasu dzisiaj")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(viewModel.status.allowedHoursText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.accentBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.accentBlue.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Circular Ring + Stats
            HStack(spacing: 24) {
                // Circular Ring
                ZStack {
                    Circle()
                        .stroke(AppColors.cardBackgroundSecondary, lineWidth: 14)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.status.progressRatio))
                        .stroke(
                            viewModel.status.progressRatio >= 1.0 ? AppColors.accentRed : AppColors.accentBlue,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 100, height: 100)
                        .animation(.easeInOut(duration: 0.6), value: viewModel.status.progressRatio)

                    VStack(spacing: 2) {
                        Text("\(Int(viewModel.status.progressRatio * 100))%")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("limitu")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppColors.textMuted)
                    }
                }

                // Stats Column
                VStack(alignment: .leading, spacing: 10) {
                    statRow(title: "Zużyto dzisiaj:", value: viewModel.status.formattedUsedTime, color: .white)
                    statRow(
                        title: "Pozostało:",
                        value: viewModel.status.formattedRemainingTime,
                        color: viewModel.status.remainingMinutes > 0 ? AppColors.accentCyan : AppColors.accentRed
                    )
                    statRow(title: "Limit dzienny:", value: viewModel.status.formattedLimitTime, color: AppColors.textSecondary)
                }
            }
            .padding(.vertical, 4)

            // Quick Bonus Buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("DODAJ DODATKOWY CZAS:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textMuted)

                HStack(spacing: 8) {
                    bonusButton(15)
                    bonusButton(30)
                    bonusButton(60, label: "+1 godz.")

                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Text("Reset ↺")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.accentRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppColors.accentRed.opacity(0.12))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.accentRed.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .modernCard()
        .confirmationDialog("Reset czasu dzisiejszego", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Zresetuj czas dziecka do zera", role: .destructive) {
                Task {
                    await viewModel.resetTodayTime()
                }
            }
            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Licznik zużytych minut na komputerze zostanie wyzerowany na dzień dzisiejszy.")
        }
    }

    private func statRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
    }

    private func bonusButton(_ minutes: Int, label: String? = nil) -> some View {
        Button {
            Task {
                await viewModel.addBonusTime(minutes)
            }
        } label: {
            Text(label ?? "+\(minutes)m")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(AppColors.cardBackgroundSecondary)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.cardBorder, lineWidth: 1))
        }
    }
}

