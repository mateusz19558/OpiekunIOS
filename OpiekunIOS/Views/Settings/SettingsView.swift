import SwiftUI

public struct SettingsView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var availableUsers: [String] = []
    @State private var targetUserMode: String = "Specific"
    @State private var targetUserName: String = ""
    @State private var newPin: String = ""
    @State private var useBiometrics: Bool = true
    @State private var showingServerSetup: Bool = false
    @State private var isSaving: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Windows User Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .foregroundColor(AppColors.accentBlue)
                                Text("MONITOROWANE KONTO WINDOWS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            Text("Opiekun wymusza blokady i harmonogram tylko na koncie dziecka. Twoje konto rodzica pozostaje bez żadnych ograniczeń.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)

                            Picker("Tryb", selection: $targetUserMode) {
                                Text("Tylko wybrane konto dziecka").tag("Specific")
                                Text("Wszystkie konta na PC").tag("All")
                            }
                            .pickerStyle(SegmentedPickerStyle())

                            if targetUserMode == "Specific" {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Wybierz konto dziecka z listy systemowej:")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textSecondary)

                                    Picker("Konto dziecka", selection: $targetUserName) {
                                        if availableUsers.isEmpty {
                                            Text(targetUserName.isEmpty ? "Dziecko" : targetUserName).tag(targetUserName)
                                        } else {
                                            ForEach(availableUsers, id: \.self) { u in
                                                Text(u).tag(u)
                                            }
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.inputBackground)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .modernCard()

                        // Parent PIN Change
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(AppColors.accentAmber)
                                Text("ZMIANA KODU PIN RODZICA")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            HStack {
                                SecureField("Nowy 4-cyfrowy PIN", text: $newPin)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(10)
                                    .background(AppColors.inputBackground)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)

                                Button("Zmień PIN") {
                                    updatePin()
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppColors.accentAmber)
                                .cornerRadius(10)
                                .disabled(newPin.count != 4)
                            }
                        }
                        .modernCard()

                        // Biometrics & Security
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(AppColors.accentGreen)
                                Text("BEZPIECZEŃSTWO APLIKACJI IOS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            Toggle(isOn: $useBiometrics) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Blokada \(BiometricAuthService.shared.biometricName)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Wymagaj uwierzytelnienia biometrycznego przy otwarciu aplikacji")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .tint(AppColors.accentGreen)
                        }
                        .modernCard()

                        // Server & Connection info
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundColor(AppColors.accentBlue)
                                Text("POŁĄCZENIE Z KOMPUTEREM")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(viewModel.profile.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(viewModel.profile.baseURLString)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                Button("Zmień...") {
                                    showingServerSetup = true
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.accentBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColors.cardBackgroundSecondary)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        }
                        .modernCard()

                        // Save All Button
                        Button {
                            saveUserSettings()
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Zapisz ustawienia użytkownika")
                                }
                            }
                        }
                        .buttonStyle(GlowingButtonStyle(gradient: AppColors.blueGradient))

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Ustawienia")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingServerSetup) {
                ServerSetupView(viewModel: viewModel)
            }
            .onAppear {
                loadInitialData()
            }
        }
    }

    private func loadInitialData() {
        targetUserMode = viewModel.status.targetUserMode
        targetUserName = viewModel.status.targetUserName

        Task {
            do {
                let res = try await APIService.shared.getUsers(profile: viewModel.profile)
                self.availableUsers = res.users
                if targetUserName.isEmpty && !res.users.isEmpty {
                    targetUserName = res.activeUser.isEmpty ? (res.users.first ?? "") : res.activeUser
                }
            } catch { }
        }
    }

    private func updatePin() {
        guard newPin.count == 4 else { return }
        Task {
            do {
                var s = try await APIService.shared.getSettings(profile: viewModel.profile)
                s.parentPin = newPin
                try await APIService.shared.saveSettings(settings: s, profile: viewModel.profile)
                viewModel.profile.pin = newPin
                newPin = ""
                viewModel.showToast("Zmieniono kod PIN rodzica! 🔑")
                HapticService.shared.notification(.success)
            } catch {
                viewModel.showToast("Błąd zmiany PIN")
            }
        }
    }

    private func saveUserSettings() {
        isSaving = true
        Task {
            do {
                var s = try await APIService.shared.getSettings(profile: viewModel.profile)
                s.targetUserMode = targetUserMode
                s.targetUserName = targetUserName
                try await APIService.shared.saveSettings(settings: s, profile: viewModel.profile)
                isSaving = false
                viewModel.status.targetUserMode = targetUserMode
                viewModel.status.targetUserName = targetUserName
                viewModel.showToast("Zapisano ustawienia konta dziecka ✓")
                HapticService.shared.notification(.success)
            } catch {
                isSaving = false
                viewModel.showToast("Błąd zapisu ustawień")
            }
        }
    }
}

