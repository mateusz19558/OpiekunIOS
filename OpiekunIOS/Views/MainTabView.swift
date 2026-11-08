import SwiftUI

public struct MainTabView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var selectedTab: Int = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Pulpit", systemImage: "shield.fill")
                }
                .badge(viewModel.status.pendingTimeRequests.filter { $0.isPending }.count)
                .tag(0)

            LiveScreenView(viewModel: viewModel)
                .tabItem {
                    Label("Ekran", systemImage: "display")
                }
                .tag(1)

            RulesView(viewModel: viewModel)
                .tabItem {
                    Label("Reguły", systemImage: "checklist")
                }
                .tag(2)

            MessagesView(viewModel: viewModel)
                .tabItem {
                    Label("Wiadomości", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(3)

            MoreMenuView(viewModel: viewModel)
                .tabItem {
                    Label("Więcej", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .tint(AppColors.accentBlue)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.secondaryBackground)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// Submenu for More options (Schedule, Logs, Settings)
public struct MoreMenuView: View {
    @ObservedObject var viewModel: GuardianViewModel

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                List {
                    Section {
                        NavigationLink {
                            WeeklyScheduleView(viewModel: viewModel)
                        } label: {
                            Label {
                                Text("Harmonogram tygodniowy i limity")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(AppColors.accentBlue)
                            }
                        }

                        NavigationLink {
                            LogsView(viewModel: viewModel)
                        } label: {
                            Label {
                                Text("Dziennik zdarzeń i diagnostyka")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "stethoscope")
                                    .foregroundColor(AppColors.accentGreen)
                            }
                        }

                        NavigationLink {
                            SettingsView(viewModel: viewModel)
                        } label: {
                            Label {
                                Text("Konto dziecka i konfiguracja")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(AppColors.accentAmber)
                            }
                        }
                    } header: {
                        Text("Zarządzanie zaawansowane")
                            .foregroundColor(AppColors.textMuted)
                    }
                    .listRowBackground(AppColors.cardBackground)

                    Section {
                        HStack {
                            Text("Wersja aplikacji")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("1.0.0 (Native iOS)")
                                .foregroundColor(AppColors.textMuted)
                        }

                        HStack {
                            Text("Status Watchdoga na PC")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("Aktywny (DACL)")
                                .foregroundColor(AppColors.accentGreen)
                        }
                    } header: {
                        Text("Informacje o systemie")
                            .foregroundColor(AppColors.textMuted)
                    }
                    .listRowBackground(AppColors.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Więcej")
        }
    }
}

