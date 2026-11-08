import SwiftUI

public struct BlockedWebsitesView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var settings: AppSettings = AppSettings()
    @State private var newDomain: String = ""
    @State private var isLoading: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Master toggle
            Toggle(isOn: Binding(
                get: { viewModel.status.blockedWebsitesEnabled },
                set: { _ in Task { await viewModel.toggleWebsitesBlock() } }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blokada stron przez systemowy plik hosts")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Przekierowuje domeny na 127.0.0.1 z odświeżeniem DNS")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .tint(AppColors.accentPurple)
            .modernCard()

            // Add new domain
            VStack(alignment: .leading, spacing: 8) {
                Text("DODAJ NOWĄ DOMENĘ")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textMuted)

                HStack(spacing: 8) {
                    TextField("np. gry.pl, tiktok.com", text: $newDomain)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Button {
                        addDomain()
                    } label: {
                        Text("+ Dodaj")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.accentPurple)
                            .cornerRadius(10)
                    }
                    .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            // Domains list
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("BLOKOWANE DOMENY (\(settings.blockedDomains.count))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textMuted)

                    Spacer()

                    if isLoading {
                        ProgressView().tint(AppColors.accentBlue)
                    }
                }

                if settings.blockedDomains.isEmpty {
                    Text("Brak zablokowanych domen")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(settings.blockedDomains, id: \.self) { domain in
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "globe.badge.chevron.backward")
                                        .foregroundColor(AppColors.accentPurple)
                                    Text(domain)
                                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                Button {
                                    removeDomain(domain)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.accentRed.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
                        }
                    }
                }
            }
        }
        .onAppear {
            loadDomains()
        }
    }

    private func loadDomains() {
        isLoading = true
        Task {
            do {
                let s = try await APIService.shared.getSettings(profile: viewModel.profile)
                self.settings = s
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }

    private func addDomain() {
        var clean = newDomain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.hasPrefix("http://") { clean = String(clean.dropFirst(7)) }
        if clean.hasPrefix("https://") { clean = String(clean.dropFirst(8)) }
        if clean.hasSuffix("/") { clean = String(clean.dropLast()) }

        guard !clean.isEmpty else { return }

        if !settings.blockedDomains.contains(clean) {
            settings.blockedDomains.append(clean)
            newDomain = ""
            saveDomains()
        }
    }

    private func removeDomain(_ domain: String) {
        settings.blockedDomains.removeAll { $0 == domain }
        saveDomains()
    }

    private func saveDomains() {
        Task {
            do {
                try await APIService.shared.saveSettings(settings: settings, profile: viewModel.profile)
                viewModel.status.blockedDomainsCount = settings.blockedDomains.count
                viewModel.showToast("Zaktualizowano blokadę stron")
                HapticService.shared.notification(.success)
            } catch {
                viewModel.showToast("Błąd zapisu")
            }
        }
    }
}

