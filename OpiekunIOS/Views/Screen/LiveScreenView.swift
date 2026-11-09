import SwiftUI
import UIKit
import Photos

public struct ShareSheet: UIViewControllerRepresentable {
    public var items: [Any]
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

public struct LiveScreenView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @StateObject private var screenVM = ScreenViewModel()

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isFullscreen: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    @State private var showShareSheet: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Control Strip (Auto-refresh & Actions)
                    HStack {
                        // Auto-refresh interval picker
                        Menu {
                            Button("Wyłączone") {
                                screenVM.setAutoRefreshInterval(0, profile: viewModel.profile)
                            }
                            Button("Co 5 sekund") {
                                screenVM.setAutoRefreshInterval(5, profile: viewModel.profile)
                            }
                            Button("Co 10 sekund") {
                                screenVM.setAutoRefreshInterval(10, profile: viewModel.profile)
                            }
                            Button("Co 30 sekund") {
                                screenVM.setAutoRefreshInterval(30, profile: viewModel.profile)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "timer")
                                Text(screenVM.autoRefreshInterval == 0 ? "Auto-odświeżanie: Wył." : "Auto: co \(screenVM.autoRefreshInterval)s")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(screenVM.autoRefreshInterval > 0 ? AppColors.accentBlue : AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                        }

                        Spacer()

                        // Manual Refresh Button
                        Button {
                            Task {
                                await screenVM.fetchScreenshot(profile: viewModel.profile)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if screenVM.isLoading {
                                    ProgressView().tint(AppColors.accentBlue)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Odśwież")
                                }
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.accentBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 16)

                    // Image Display Canvas
                    GeometryReader { geo in
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.cardBackground)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))

                            if screenVM.image != nil {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(scale)
                                    .gesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                scale = lastScale * value
                                            }
                                            .onEnded { _ in
                                                lastScale = scale
                                                if scale < 1.0 {
                                                    withAnimation(.spring()) {
                                                        scale = 1.0
                                                        lastScale = 1.0
                                                    }
                                                }
                                            }
                                    )
                                    .onTapGesture(count: 2) {
                                        withAnimation(.spring()) {
                                            if scale > 1.0 {
                                                scale = 1.0
                                                lastScale = 1.0
                                            } else {
                                                scale = 2.0
                                                lastScale = 2.0
                                            }
                                        }
                                    }
                            } else {
                                VStack(spacing: 12) {
                                    if screenVM.isLoading {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .tint(AppColors.accentBlue)
                                        Text("Pobieranie zrzutu ekranu...")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColors.textSecondary)
                                    } else {
                                        Image(systemName: "display")
                                            .font(.system(size: 48))
                                            .foregroundColor(AppColors.textMuted)
                                        Text("Kliknij 'Odśwież', aby pobrać widok pulpitu dziecka")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColors.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 30)
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16)

                    // Info & Bottom Actions
                    VStack(spacing: 12) {
                        HStack {
                            if let time = screenVM.lastRefreshTime {
                                Text("Ostatnia aktualizacja: \(time.formatted(date: .omitted, time: .standard))")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textMuted)
                            } else {
                                Text("Brak pobranego obrazu")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            Spacer()

                            Text("Przybliż dwoma palcami")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textMuted)
                        }

                        // Save & Share Buttons
                        if screenVM.image != nil {
                            HStack(spacing: 12) {
                                Button {
                                    screenVM.saveToPhotos { success, msg in
                                        saveAlertMessage = msg ?? ""
                                        showSaveAlert = true
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Zapisz w Zdjęciach")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.cardBorder, lineWidth: 1))
                                }

                                Button {
                                    showShareSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Udostępnij")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.accentBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppColors.accentBlue.opacity(0.12))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Podgląd Ekranu HD")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let img = screenVM.image {
                    ShareSheet(items: [img])
                }
            }
            .alert("Zapisano", isPresented: $showSaveAlert) {
                Button("OK") {}
            } message: {
                Text(saveAlertMessage)
            }
            .onAppear {
                if screenVM.image == nil {
                    Task {
                        await screenVM.fetchScreenshot(profile: viewModel.profile)
                    }
                }
            }
            .onDisappear {
                screenVM.stopAutoRefresh()
            }
        }
    }
}
