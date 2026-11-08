import SwiftUI

public struct WeeklyScheduleView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @StateObject private var scheduleVM = ScheduleViewModel()

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Master Schedule Toggle
                        Toggle(isOn: $scheduleVM.settings.scheduleEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Automatyczny harmonogram dzienny")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Komputer blokuje się po przekroczeniu limitu lub poza dozwolonymi godzinami")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .tint(AppColors.accentBlue)
                        .modernCard()

                        // Quick actions row
                        HStack(spacing: 8) {
                            Button("Kopiuj Pon->Pt") {
                                scheduleVM.copyWeekdaysToAll()
                                viewModel.showToast("Skopiowano na dni robocze")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))

                            Button("Kopiuj Sob->Ndz") {
                                scheduleVM.copyWeekend()
                                viewModel.showToast("Skopiowano weekend")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))

                            Button("Domyślne ↺") {
                                scheduleVM.resetToDefaults()
                                viewModel.showToast("Przywrócono domyślny harmonogram")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.accentRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
                        }

                        // Days of Week List
                        VStack(spacing: 12) {
                            ForEach(scheduleVM.daysOrder, id: \.self) { dayKey in
                                if let day = scheduleVM.settings.weeklySchedule[dayKey] {
                                    dayScheduleCard(dayKey: dayKey, day: day)
                                }
                            }
                        }

                        // Save Button
                        Button {
                            Task {
                                let success = await scheduleVM.saveSettings(profile: viewModel.profile)
                                if success {
                                    viewModel.showToast("Harmonogram pomyślnie zapisany! 💾")
                                    await viewModel.refreshStatus()
                                }
                            }
                        } label: {
                            HStack {
                                if scheduleVM.isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Zapisz harmonogram na komputerze")
                                }
                            }
                        }
                        .buttonStyle(GlowingButtonStyle(gradient: AppColors.blueGradient))

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Harmonogram Tygodniowy")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await scheduleVM.loadSettings(profile: viewModel.profile)
                }
            }
        }
    }

    private func dayScheduleCard(dayKey: String, day: DaySchedule) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(scheduleVM.dayNamesPolish[dayKey] ?? dayKey)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { scheduleVM.settings.weeklySchedule[dayKey]?.enabled ?? true },
                    set: { scheduleVM.settings.weeklySchedule[dayKey]?.enabled = $0 }
                ))
                .labelsHidden()
                .tint(AppColors.accentGreen)
            }

            if scheduleVM.settings.weeklySchedule[dayKey]?.enabled == true {
                Divider().background(AppColors.cardBorder)

                // Allowed Hours Pickers
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Od godziny:")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textMuted)

                        TextField("14:00", text: Binding(
                            get: { scheduleVM.settings.weeklySchedule[dayKey]?.startTime ?? "14:00" },
                            set: { scheduleVM.settings.weeklySchedule[dayKey]?.startTime = $0 }
                        ))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.accentBlue)
                        .padding(8)
                        .background(AppColors.inputBackground)
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Do godziny:")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textMuted)

                        TextField("20:00", text: Binding(
                            get: { scheduleVM.settings.weeklySchedule[dayKey]?.endTime ?? "20:00" },
                            set: { scheduleVM.settings.weeklySchedule[dayKey]?.endTime = $0 }
                        ))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.accentBlue)
                        .padding(8)
                        .background(AppColors.inputBackground)
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Limit minut:")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textMuted)

                        TextField("120", value: Binding(
                            get: { scheduleVM.settings.weeklySchedule[dayKey]?.maxMinutes ?? 120 },
                            set: { scheduleVM.settings.weeklySchedule[dayKey]?.maxMinutes = $0 }
                        ), formatter: NumberFormatter())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.accentGreen)
                        .keyboardType(.numberPad)
                        .padding(8)
                        .background(AppColors.inputBackground)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .modernCard()
    }
}

