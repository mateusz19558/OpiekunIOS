import SwiftUI

public struct LogsView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @StateObject private var logsVM = LogsViewModel()
    @State private var showingClearConfirmation = false

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 12) {
                    // Search & Filters
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textMuted)
                            TextField("Filtruj logi po treści lub źródle...", text: $logsVM.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.white)
                            if !logsVM.searchText.isEmpty {
                                Button {
                                    logsVM.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.textMuted)
                                }
                            }
                        }
                        .padding(10)
                        .background(AppColors.cardBackground)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.cardBorder, lineWidth: 1))

                        // Filter Pills
                        HStack(spacing: 8) {
                            filterPill("WSZYSTKIE", tag: "ALL")
                            filterPill("BŁĘDY", tag: "ERROR", color: AppColors.accentRed)
                            filterPill("OSTRZEŻENIA", tag: "WARN", color: AppColors.accentAmber)
                            filterPill("INFO", tag: "INFO", color: AppColors.accentBlue)

                            Spacer()

                            Button {
                                showingClearConfirmation = true
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.accentRed)
                                    .padding(8)
                                    .background(AppColors.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Logs List
                    if logsVM.isLoading {
                        Spacer()
                        ProgressView("Ładowanie zdarzeń z komputera...")
                            .tint(AppColors.accentBlue)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    } else if logsVM.filteredLogs.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.accentGreen.opacity(0.8))
                            Text("Brak zarejestrowanych błędów")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("System działa stabilnie bez wyjątków krytycznych.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(logsVM.filteredLogs) { entry in
                                logCard(entry)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Dziennik Zdarzeń")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await logsVM.loadLogs(profile: viewModel.profile) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
            }
            .confirmationDialog("Czyszczenie dziennika", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                Button("Wyczyść wszystkie logi na PC", role: .destructive) {
                    Task {
                        await logsVM.clearLogs(profile: viewModel.profile)
                        viewModel.showToast("Wyczyszczono dziennik zdarzeń")
                    }
                }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Czy na pewno chcesz usunąć całą historię błędów z pliku error.log?")
            }
            .onAppear {
                Task {
                    await logsVM.loadLogs(profile: viewModel.profile)
                }
            }
        }
    }

    private func filterPill(_ title: String, tag: String, color: Color = AppColors.accentBlue) -> some View {
        Button {
            logsVM.selectedFilter = tag
            HapticService.shared.selection()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(logsVM.selectedFilter == tag ? .white : AppColors.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(logsVM.selectedFilter == tag ? color : AppColors.cardBackground)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.cardBorder, lineWidth: 1))
        }
    }

    private func logCard(_ entry: LogEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.level)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(levelColor(entry.level))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(levelColor(entry.level).opacity(0.15))
                    .clipShape(Capsule())

                Text(entry.source)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(entry.timestamp)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(AppColors.textMuted)
            }

            Text(entry.message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            if let details = entry.exceptionDetails, !details.isEmpty {
                Text(details)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(AppColors.textMuted)
                    .lineLimit(3)
                    .padding(6)
                    .background(AppColors.inputBackground)
                    .cornerRadius(6)
            }
        }
        .modernCard()
    }

    private func levelColor(_ level: String) -> Color {
        switch level.uppercased() {
        case "ERROR": return AppColors.accentRed
        case "WARN": return AppColors.accentAmber
        default: return AppColors.accentBlue
        }
    }
}

