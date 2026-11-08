import SwiftUI

public struct ScheduledLockSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GuardianViewModel
    @State private var selectedMinutes: Double = 20

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("⏳")
                            .font(.system(size: 48))

                        Text("Zaplanuj automatyczną blokadę")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("Komputer zostanie zablokowany po upływie zadanego czasu.")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Display Value
                    VStack(spacing: 4) {
                        Text("\(Int(selectedMinutes))")
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.accentAmber)
                        Text("MINUT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textMuted)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))

                    // Slider
                    Slider(value: $selectedMinutes, in: 5...180, step: 5)
                        .tint(AppColors.accentAmber)

                    // Quick presets
                    HStack(spacing: 8) {
                        ForEach([15, 30, 45, 60, 90, 120], id: \.self) { min in
                            Button("\(min)m") {
                                selectedMinutes = Double(min)
                                HapticService.shared.selection()
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedMinutes == Double(min) ? AppColors.accentAmber : AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedMinutes == Double(min) ? AppColors.accentAmber.opacity(0.2) : AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedMinutes == Double(min) ? AppColors.accentAmber : AppColors.cardBorder, lineWidth: 1))
                        }
                    }

                    Spacer()

                    // Confirm button
                    Button {
                        Task {
                            await viewModel.scheduleLock(minutes: Int(selectedMinutes))
                            dismiss()
                        }
                    } label: {
                        Text("Aktywuj blokadę za \(Int(selectedMinutes)) min")
                    }
                    .buttonStyle(GlowingButtonStyle(gradient: AppColors.lockGradient))
                }
                .padding(24)
            }
            .navigationTitle("Zaplanuj Blokadę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

