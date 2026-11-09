import SwiftUI

public struct DashboardView: View {
    @ObservedObject var viewModel: GuardianViewModel

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Top Status Bar (PC Name, User, Pulse Indicator)
                        HStack(alignment: .center) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke((viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed).opacity(0.4), lineWidth: 3)
                                            .scaleEffect(viewModel.isConnected ? 1.4 : 1.0)
                                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: viewModel.isConnected)
                                    )

                                Text(viewModel.isConnected ? "POŁĄCZONO NA ŻYWO" : "BRAK POŁĄCZENIA")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(viewModel.isConnected ? AppColors.accentGreen : AppColors.accentRed)
                            }

                            Spacer()

                            // Connection Mode Switcher (Wi-Fi Dom / LTE Zdalnie)
                            Menu {
                                ForEach(ConnectionMode.allCases, id: \.self) { m in
                                    Button {
                                        viewModel.switchConnectionMode(m)
                                    } label: {
                                        HStack {
                                            Text(m.rawValue)
                                            if viewModel.profile.mode == m {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: viewModel.profile.isCurrentlyUsingRemote ? "globe" : "house.fill")
                                        .font(.system(size: 11))
                                    Text(viewModel.profile.isCurrentlyUsingRemote ? "Poza domem" : "Dom (Wi-Fi)")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(viewModel.profile.isCurrentlyUsingRemote ? AppColors.accentCyan : AppColors.accentBlue)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(AppColors.cardBackground)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                            }

                            // Active Windows user badge
                            HStack(spacing: 4) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 12))
                                Text(viewModel.status.currentActiveUser.isEmpty ? "Wszyscy" : viewModel.status.currentActiveUser)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                        }
                        .padding(.horizontal, 4)

                        // Sleep / Login Screen notification banner
                        if viewModel.status.isDesktopLockedOrSleeping == true {
                            HStack(spacing: 8) {
                                Text("💤")
                                    .font(.system(size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("KOMPUTER UŚPIONY LUB EKRAN LOGOWANIA")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(AppColors.accentBlue)
                                    Text("Czas dziecka jest wstrzymany. Odliczanie ruszy dopiero po zalogowaniu na pulpit.")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(Color(hex: 0x1e3a8a).opacity(0.35))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.accentBlue.opacity(0.4), lineWidth: 1))
                        }

                        // Pending Time Requests Banners
                        ForEach(viewModel.status.pendingTimeRequests.filter { $0.isPending }) { req in
                            TimeRequestAlertBanner(viewModel: viewModel, request: req)
                        }

                        // Master Lock Card
                        LockControlCard(viewModel: viewModel)

                        // Remote Mode Card (Tryb Zdalny)
                        RemoteModeCard(viewModel: viewModel)

                        // Activity Gauge & Time Usage Card
                        TimeUsageRingCard(viewModel: viewModel)

                        // Quick Actions Grid (Firewall, Websites, Apps, Settings)
                        QuickActionGrid(viewModel: viewModel)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await viewModel.refreshStatus()
                }

                // Toast Notification Overlay
                if let toast = viewModel.toastMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.accentGreen)
                            Text(toast)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.cardBackgroundSecondary)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 5)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.toastMessage)
                }
            }
            .navigationTitle("Pulpit Opiekuna")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Text("🛡️")
                        Text(viewModel.profile.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticService.shared.selection()
                        Task { await viewModel.refreshStatus() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
            }
        }
    }
}

// MARK: - Remote Mode Card (Tryb Zdalny)
public struct RemoteModeCard: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var showRemoteDesktop: Bool = false

    private var isRemoteActive: Bool {
        viewModel.status.isRemoteModeActive ?? false
    }

    private var isInputBlocked: Bool {
        viewModel.status.blockRemoteInput ?? false
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isRemoteActive ? AppColors.accentCyan.opacity(0.18) : AppColors.cardBackgroundSecondary)
                            .frame(width: 42, height: 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isRemoteActive ? AppColors.accentCyan.opacity(0.6) : AppColors.cardBorder, lineWidth: 1)
                            )

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TRYB ZDALNY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textPrimary)

                        Text("Szara tapeta i znak wodny na PC")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textMuted)
                    }
                }

                Spacer()

                // Active badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                        .frame(width: 6, height: 6)
                    Text(isRemoteActive ? "AKTYWNY" : "WYŁĄCZONY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isRemoteActive ? AppColors.accentCyan : AppColors.textMuted)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(isRemoteActive ? AppColors.accentCyan.opacity(0.12) : AppColors.cardBackgroundSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isRemoteActive ? AppColors.accentCyan.opacity(0.4) : AppColors.cardBorder, lineWidth: 1)
                )
            }

            // Main Toggle Button
            Button {
                Task {
                    await viewModel.toggleRemoteMode()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isRemoteActive ? "stop.circle.fill" : "play.circle.fill")
                    Text(isRemoteActive ? "Zakończ tryb zdalny" : "Uruchom tryb zdalny")
                }
            }
            .buttonStyle(GlowingButtonStyle(
                gradient: isRemoteActive
                    ? LinearGradient(colors: [Color(hex: 0xb91c1c), Color(hex: 0xef4444)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(hex: 0x0284c7), Color(hex: 0x38bdf8)], startPoint: .leading, endPoint: .trailing)
            ))

            // Sub-control: Block Mouse and Keyboard slider / toggle (Only during Remote Mode)
            if isRemoteActive {
                VStack(spacing: 10) {
                    Divider().background(AppColors.cardBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Image(systemName: isInputBlocked ? "keyboard.badge.ellipsis" : "keyboard")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isInputBlocked ? AppColors.accentRed : AppColors.accentCyan)

                                    Text("Blokada myszy i klawiatury")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Text("Dziecko nie może ruszać kursorem ani pisać")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textMuted)
                            }

                            Spacer()

                            // Interactive Toggle Switch
                            Toggle("", isOn: Binding(
                                get: { isInputBlocked },
                                set: { val in
                                    Task {
                                        await viewModel.setRemoteInputBlocked(val)
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(AppColors.accentRed)
                        }

                        // Status pill for input lock
                        HStack(spacing: 6) {
                            Image(systemName: isInputBlocked ? "lock.fill" : "lock.open.fill")
                                .font(.system(size: 11))
                            Text(isInputBlocked ? "Klawiatura i mysz są ZABLOKOWANE" : "Sterowanie dziecka jest DOZWOLONE")
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(isInputBlocked ? Color(hex: 0xfca5a5) : Color(hex: 0x86efac))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            (isInputBlocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.12)
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke((isInputBlocked ? AppColors.accentRed : AppColors.accentGreen).opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Button to launch live screen streaming & remote mouse/keyboard control
                    Button {
                        showRemoteDesktop = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "display.and.cursorarrow")
                                .font(.system(size: 15, weight: .bold))
                            Text("Otwórz Zdalny Pulpit i Sterowanie")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [Color(hex: 0x0891b2), Color(hex: 0x06b6d4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(hex: 0x06b6d4).opacity(0.35), radius: 6, y: 3)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .modernCard()
        .animation(.easeInOut(duration: 0.25), value: isRemoteActive)
        .animation(.easeInOut(duration: 0.2), value: isInputBlocked)
        .fullScreenCover(isPresented: $showRemoteDesktop) {
            RemoteDesktopView(viewModel: viewModel)
        }
    }
}

// MARK: - Remote Desktop Interactive Screen & Control View
public struct RemoteDesktopView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentImage: UIImage?
    @State private var isStreaming: Bool = false
    @State private var streamTask: Task<Void, Never>?

    // Mouse & Click states
    @State private var selectedMouseAction: String = "click"
    @State private var tapRippleLocation: CGPoint?
    @State private var showRipple: Bool = false

    // Keyboard bar
    @State private var showKeyboardBar: Bool = false
    @State private var inputText: String = ""

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation & Status Bar
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: 0x22c55e))
                            .frame(width: 8, height: 8)
                        Text("ZDALNY PULPIT PC")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)

                        if viewModel.status.blockRemoteInput == true {
                            Text("MYSZ DZIECKA: BLOK")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(AppColors.accentRed)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.accentRed.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }

                    Spacer()

                    Button {
                        stopStreaming()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: 0x111827))

                // Interactive Screen Canvas
                GeometryReader { geo in
                    ZStack {
                        Color.black

                        if let img = currentImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay(
                                    GeometryReader { imgGeo in
                                        Color.clear
                                            .contentShape(Rectangle())
                                            .gesture(
                                                DragGesture(minimumDistance: 0)
                                                    .onEnded { value in
                                                        handleScreenTap(at: value.location, in: imgGeo.size)
                                                    }
                                            )
                                    }
                                )
                        } else {
                            VStack(spacing: 12) {
                                ProgressView().tint(.white).scaleEffect(1.3)
                                Text("Łączenie z ekranem PC...")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        // Tap Ripple Effect
                        if showRipple, let ripple = tapRippleLocation {
                            Circle()
                                .stroke(Color(hex: 0x38bdf8), lineWidth: 2)
                                .frame(width: 32, height: 32)
                                .position(ripple)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                // Keyboard Input Drawer (if open)
                if showKeyboardBar {
                    HStack(spacing: 8) {
                        TextField("Wpisz tekst do wysłania na PC...", text: $inputText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: 0x1f2937))
                            .cornerRadius(8)

                        Button {
                            guard !inputText.isEmpty else { return }
                            let textToSend = inputText
                            inputText = ""
                            Task {
                                await viewModel.sendRemoteKeyboard(text: textToSend)
                            }
                        } label: {
                            Text("Wyślij")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(hex: 0x0284c7))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: 0x111827))
                }

                // Control Toolbar
                VStack(spacing: 6) {
                    // Quick special keys row
                    HStack(spacing: 8) {
                        toolbarKeyButton(title: "Enter ↵") {
                            Task { await viewModel.sendRemoteKeyboard(key: "enter") }
                        }
                        toolbarKeyButton(title: "⌫ Kasuj") {
                            Task { await viewModel.sendRemoteKeyboard(key: "backspace") }
                        }
                        toolbarKeyButton(title: "Esc") {
                            Task { await viewModel.sendRemoteKeyboard(key: "esc") }
                        }
                        toolbarKeyButton(title: "Tab ⇥") {
                            Task { await viewModel.sendRemoteKeyboard(key: "tab") }
                        }
                        toolbarKeyButton(title: "🪟 Pulpit") {
                            Task { await viewModel.sendRemoteKeyboard(key: "win_d") }
                        }
                    }

                    // Mouse actions row
                    HStack(spacing: 10) {
                        mouseActionButton(title: "LPM", icon: "cursorarrow.click", action: "click")
                        mouseActionButton(title: "PPM (Prawy)", icon: "cursorarrow.click.badge.shapes", action: "right_click")
                        mouseActionButton(title: "2x Klik", icon: "cursorarrow.rays", action: "double_click")

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showKeyboardBar.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: showKeyboardBar ? "keyboard.chevron.compact.down" : "keyboard")
                                Text(showKeyboardBar ? "Schowaj" : "Klawiatura")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(showKeyboardBar ? Color(hex: 0x0284c7) : Color(hex: 0x374151))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: 0x111827))
            }
        }
        .onAppear {
            startStreaming()
        }
        .onDisappear {
            stopStreaming()
        }
    }

    private func handleScreenTap(at location: CGPoint, in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }

        tapRippleLocation = location
        withAnimation(.easeOut(duration: 0.3)) {
            showRipple = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showRipple = false
        }

        let normX = min(max(Double(location.x / size.width), 0.0), 1.0)
        let normY = min(max(Double(location.y / size.height), 0.0), 1.0)

        let action = selectedMouseAction
        HapticService.shared.impact(.light)

        Task {
            await viewModel.sendRemoteMouse(x: normX, y: normY, action: action)
        }

        // Reset to default click after special right/double click
        if selectedMouseAction != "click" {
            selectedMouseAction = "click"
        }
    }

    private func mouseActionButton(title: String, icon: String, action: String) -> some View {
        Button {
            selectedMouseAction = action
            HapticService.shared.selection()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(selectedMouseAction == action ? .white : Color(hex: 0x9ca3af))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(selectedMouseAction == action ? Color(hex: 0x0284c7) : Color(hex: 0x1f2937))
            .cornerRadius(8)
        }
    }

    private func toolbarKeyButton(title: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticService.shared.impact(.light)
            action()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(hex: 0x1f2937))
                .cornerRadius(6)
        }
    }

    private func startStreaming() {
        isStreaming = true
        streamTask = Task {
            while !Task.isCancelled && isStreaming {
                if let img = try? await APIService.shared.fetchRemoteScreen(quality: 50, profile: viewModel.profile) {
                    await MainActor.run {
                        self.currentImage = img
                    }
                }
                try? await Task.sleep(nanoseconds: 700_000_000)
            }
        }
    }

    private func stopStreaming() {
        isStreaming = false
        streamTask?.cancel()
        streamTask = nil
    }
}

