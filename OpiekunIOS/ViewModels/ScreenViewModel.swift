import Foundation
import UIKit
import Photos

@MainActor
public final class ScreenViewModel: ObservableObject {
    @Published public var image: UIImage? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastRefreshTime: Date? = nil
    @Published public var autoRefreshInterval: Int = 0 // 0 = off, 5, 10, 30

    private var autoRefreshTimer: Timer?

    public init() {}

    public func fetchScreenshot(profile: ConnectionProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            let img = try await APIService.shared.fetchScreenshot(profile: profile)
            self.image = img
            self.lastRefreshTime = Date()
            self.isLoading = false
            HapticService.shared.selection()
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func setAutoRefreshInterval(_ interval: Int, profile: ConnectionProfile) {
        self.autoRefreshInterval = interval
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil

        guard interval > 0 else { return }

        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, !self.isLoading else { return }
                await self.fetchScreenshot(profile: profile)
            }
        }
    }

    public func saveToPhotos(completion: @escaping (Bool, String?) -> Void) {
        guard let image = image else {
            completion(false, "Brak obrazu do zapisania")
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, "Brak uprawnień do Galerii Zdjęć")
                }
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                HapticService.shared.notification(.success)
                completion(true, "Zrzut ekranu zapisano w Zdjęciach!")
            }
        }
    }

    public func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    deinit {
        autoRefreshTimer?.invalidate()
    }
}

