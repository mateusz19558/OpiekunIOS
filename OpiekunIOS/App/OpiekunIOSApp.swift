import SwiftUI

@main
struct OpiekunIOSApp: App {
    @StateObject private var viewModel = GuardianViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if viewModel.isAuthenticated {
                    MainTabView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    PinAuthView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.35), value: viewModel.isAuthenticated)
            .onAppear {
                Task {
                    _ = await NotificationService.shared.requestAuthorization()
                }
            }
        }
    }
}

