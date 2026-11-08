import SwiftUI
import AVFoundation

public struct ServerSetupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GuardianViewModel

    @State private var profileName: String = ""
    @State private var host: String = ""
    @State private var port: String = "5050"
    @State private var pin: String = "1234"
    @State private var useHttps: Bool = false
    @State private var showingScanner: Bool = false
    @State private var testResult: String? = nil
    @State private var isTesting: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // QR Scan Banner
                        Button {
                            HapticService.shared.selection()
                            showingScanner = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentBlue.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.accentBlue)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Zeskanuj kod QR z komputera")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Skieruj aparat na okno z kodem QR na ekranie PC")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppColors.textMuted)
                            }
                            .modernCard()
                        }

                        // Form settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Parametry połączenia")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColors.textMuted)
                                .textCase(.uppercase)

                            VStack(spacing: 12) {
                                inputField(title: "Nazwa profilu", placeholder: "np. Komputer Michała", text: $profileName)
                                inputField(title: "Adres IP / Host / Tunel", placeholder: "np. 192.168.1.150 lub domena.trycloudflare.com", text: $host)

                                if !host.lowercased().hasPrefix("https://") && !host.lowercased().hasPrefix("http://") {
                                    inputField(title: "Port serwera", placeholder: "5050", text: $port, keyboardType: .numberPad)

                                    Toggle(isOn: $useHttps) {
                                        Text("Używaj szyfrowania HTTPS")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .tint(AppColors.accentBlue)
                                }

                                inputField(title: "Kod PIN Rodzica", placeholder: "1234", text: $pin, isSecure: true, keyboardType: .numberPad)
                            }
                        }
                        .modernCard()

                        // Test Connection Button
                        Button {
                            testConnection()
                        } label: {
                            HStack {
                                if isTesting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                    Text("Przetestuj połączenie z PC")
                                }
                            }
                        }
                        .buttonStyle(GlowingButtonStyle(gradient: AppColors.blueGradient))
                        .disabled(isTesting || host.isEmpty)

                        if let res = testResult {
                            Text(res)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(res.contains("sukcesem") ? AppColors.accentGreen : AppColors.accentRed)
                                .padding()
                                .modernCard()
                        }

                        // Cloudflare instructions
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text("🌐")
                                Text("Dostęp poza siecią domową WiFi")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("Aby sterować komputerem przez LTE / dane komórkowe z dowolnego miejsca, uruchom na PC tunel Cloudflare:\n\ncloudflared tunnel --url http://localhost:5050\n\ni wklej wygenerowany adres https:// w pole powyżej.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(3)
                        }
                        .modernCard()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Konfiguracja Serwera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        saveProfile()
                        dismiss()
                    }
                    .foregroundColor(AppColors.accentBlue)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingScanner) {
                QRCodeScannerView { scannedCode in
                    handleScannedCode(scannedCode)
                    showingScanner = false
                }
            }
            .onAppear {
                profileName = viewModel.profile.name
                host = viewModel.profile.host
                port = "\(viewModel.profile.port)"
                pin = viewModel.profile.pin
                useHttps = viewModel.profile.useHttps
            }
        }
    }

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)

            if isSecure {
                SecureField(placeholder, text: text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(AppColors.inputBackground)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(AppColors.inputBackground)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        // Code could be "http://192.168.1.150:5050" or "https://xxx.trycloudflare.com"
        HapticService.shared.notification(.success)
        if let url = URL(string: code) {
            if let hostStr = url.host {
                self.host = hostStr
            }
            if let portNum = url.port {
                self.port = "\(portNum)"
            }
            self.useHttps = url.scheme == "https"
        } else {
            self.host = code
        }
    }

    private func saveProfile() {
        let p = Int(port) ?? 5050
        viewModel.profile.name = profileName.isEmpty ? "Komputer Dziecka" : profileName
        viewModel.profile.host = host
        viewModel.profile.port = p
        viewModel.profile.pin = pin
        viewModel.profile.useHttps = useHttps
        HapticService.shared.notification(.success)
    }

    private func testConnection() {
        isTesting = true
        testResult = nil

        let testProfile = ConnectionProfile(
            name: profileName,
            host: host,
            port: Int(port) ?? 5050,
            pin: pin,
            useHttps: useHttps
        )

        Task {
            do {
                let status = try await APIService.shared.getStatus(profile: testProfile)
                isTesting = false
                testResult = "Połączono z sukcesem! PC aktywny. Użytkownik: \(status.activeUserName)"
                HapticService.shared.notification(.success)
            } catch {
                isTesting = false
                testResult = "Błąd: \(error.localizedDescription)"
                HapticService.shared.notification(.error)
            }
        }
    }
}

