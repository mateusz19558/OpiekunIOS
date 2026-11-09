import SwiftUI
import AVFoundation

public struct ServerSetupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GuardianViewModel

    @State private var profileName: String = ""
    @State private var host: String = ""
    @State private var port: String = "5050"
    @State private var remoteURL: String = ""
    @State private var mode: ConnectionMode = .auto
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

                        // Tryb połączenia
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TRYB POŁĄCZENIA")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)

                            Picker("Tryb", selection: $mode) {
                                ForEach(ConnectionMode.allCases, id: \.self) { m in
                                    Text(m.rawValue).tag(m)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())

                            Text(modeExplanation)
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.top, 2)
                        }
                        .modernCard()

                        // Adres domowy Wi-Fi
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(AppColors.accentBlue)
                                Text("POŁĄCZENIE W DOMU (LOKALNE WI-FI)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            VStack(spacing: 12) {
                                inputField(title: "Adres IP komputera w domu", placeholder: "np. 192.168.1.150", text: $host)
                                inputField(title: "Port serwera", placeholder: "5050", text: $port, keyboardType: .numberPad)
                            }
                        }
                        .modernCard()

                        // Adres zdalny poza domem
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(AppColors.accentCyan)
                                Text("POŁĄCZENIE POZA DOMEM (LTE / INTERNET)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            VStack(spacing: 12) {
                                inputField(
                                    title: "Adres tunelu Cloudflare HTTPS",
                                    placeholder: "np. https://twoj-tunel.trycloudflare.com",
                                    text: $remoteURL
                                )

                                Text("Wygeneruj darmowy link na PC uruchamiając plik 'Uruchom_Zdalny_Dostep_Poza_Domem.bat'")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                        .modernCard()

                        // PIN i Profil
                        VStack(alignment: .leading, spacing: 14) {
                            Text("AUTORYZACJA")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)

                            VStack(spacing: 12) {
                                inputField(title: "Nazwa komputera", placeholder: "np. Komputer Dziecka", text: $profileName)
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
                        .disabled(isTesting || (host.isEmpty && remoteURL.isEmpty))

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
                                Text("Jak działa sterowanie poza domem?")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("1. Na komputerze na Pulpicie uruchom plik: Uruchom_Zdalny_Dostep_Poza_Domem.bat\n2. Program wyświetli bezpieczny adres https://...trycloudflare.com\n3. Wklej ten adres w pole powyżej i włącz tryb 'Automatyczny'.\n4. Telefon sam połączy się przez Wi-Fi w domu, a gdy wyjdziesz z domu – przez LTE!")
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
                remoteURL = viewModel.profile.remoteURL
                mode = viewModel.profile.mode
                pin = viewModel.profile.pin
                useHttps = viewModel.profile.useHttps
            }
        }
    }

    private var modeExplanation: String {
        switch mode {
        case .auto:
            return "W domu aplikacja łączy się błyskawicznie po Wi-Fi. Po wyjściu z domu automatycznie przełącza się na tunel LTE."
        case .local:
            return "Połączenie tylko w domowej sieci Wi-Fi pod adresem IP."
        case .remote:
            return "Wymuszenie połączenia przez adres zewnętrzny / tunel Cloudflare."
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
        HapticService.shared.notification(.success)
        if let url = URL(string: code) {
            if code.contains("trycloudflare") || code.contains("ngrok") {
                self.remoteURL = code
            } else {
                if let hostStr = url.host {
                    self.host = hostStr
                }
                if let portNum = url.port {
                    self.port = "\(portNum)"
                }
            }
        } else {
            self.host = code
        }
    }

    private func saveProfile() {
        let p = Int(port) ?? 5050
        viewModel.profile.name = profileName.isEmpty ? "Komputer Dziecka" : profileName
        viewModel.profile.host = host
        viewModel.profile.port = p
        viewModel.profile.remoteURL = remoteURL
        viewModel.profile.mode = mode
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
            remoteURL: remoteURL,
            mode: mode,
            pin: pin,
            useHttps: useHttps
        )

        Task {
            do {
                let status = try await APIService.shared.getStatus(profile: testProfile)
                isTesting = false
                let connType = testProfile.isCurrentlyUsingRemote ? "Zdalne (LTE/Tunel)" : "Lokalne (Wi-Fi)"
                testResult = "Połączono z sukcesem! [\(connType)] Użytkownik PC: \(status.activeUserName)"
                HapticService.shared.notification(.success)
            } catch {
                isTesting = false
                testResult = "Błąd: \(error.localizedDescription)"
                HapticService.shared.notification(.error)
            }
        }
    }
}
