import SwiftUI

public struct PinAuthView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var enteredPin: String = ""
    @State private var isShaking: Bool = false
    @State private var showingServerSetup: Bool = false

    private let maxPinLength = 4

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 28) {
                // Top header
                HStack {
                    Spacer()
                    Button {
                        HapticService.shared.selection()
                        showingServerSetup = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "network")
                            Text("Serwer")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.accentBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.cardBackground)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 10)

                // Brand Logo & Titles
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.cardBackground)
                            .frame(width: 88, height: 88)
                            .overlay(Circle().stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 2))
                            .shadow(color: AppColors.accentBlue.opacity(0.2), radius: 15)

                        Text("🛡️")
                            .font(.system(size: 44))
                    }

                    Text("Opiekun PC")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("Wprowadź 4-cyfrowy kod PIN rodzica")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)

                    Text(viewModel.profile.baseURLString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(AppColors.textMuted)
                }

                // PIN Dots
                HStack(spacing: 20) {
                    ForEach(0..<maxPinLength, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPin.count ? AppColors.accentBlue : AppColors.cardBackground)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle().stroke(index < enteredPin.count ? AppColors.accentBlue : AppColors.cardBorder, lineWidth: 2)
                            )
                            .shadow(color: index < enteredPin.count ? AppColors.accentBlue.opacity(0.6) : .clear, radius: 8)
                            .scaleEffect(index < enteredPin.count ? 1.15 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: enteredPin.count)
                    }
                }
                .offset(x: isShaking ? -10 : 0)
                .animation(isShaking ? .default.repeatCount(4, autoreverses: true).speed(4) : .default, value: isShaking)
                .padding(.vertical, 8)

                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.accentRed)
                        .transition(.opacity)
                }

                Spacer(minLength: 10)

                // Numpad Grid
                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        numpadButton("1")
                        numpadButton("2")
                        numpadButton("3")
                    }
                    HStack(spacing: 24) {
                        numpadButton("4")
                        numpadButton("5")
                        numpadButton("6")
                    }
                    HStack(spacing: 24) {
                        numpadButton("7")
                        numpadButton("8")
                        numpadButton("9")
                    }
                    HStack(spacing: 24) {
                        // FaceID or Clear
                        if BiometricAuthService.shared.isBiometricAvailable {
                            Button {
                                triggerBiometrics()
                            } label: {
                                Image(systemName: BiometricAuthService.shared.biometricType == .faceID ? "faceid" : "touchid")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.accentBlue)
                                    .frame(width: 76, height: 76)
                                    .background(AppColors.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        } else {
                            Button {
                                clearPin()
                            } label: {
                                Text("C")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)
                                    .frame(width: 76, height: 76)
                                    .background(AppColors.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        }

                        numpadButton("0")

                        Button {
                            backspacePin()
                        } label: {
                            Image(systemName: "delete.left.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.textMuted)
                                .frame(width: 76, height: 76)
                                .background(AppColors.cardBackground)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppColors.cardBorder, lineWidth: 1))
                        }
                    }
                }

                Spacer(minLength: 20)
            }
        }
        .sheet(isPresented: $showingServerSetup) {
            ServerSetupView(viewModel: viewModel)
        }
        .onAppear {
            if !viewModel.profile.pin.isEmpty {
                // Auto try biometrics on launch if available
                triggerBiometrics()
            }
        }
    }

    private func numpadButton(_ number: String) -> some View {
        Button {
            appendDigit(number)
        } label: {
            Text(number)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 76, height: 76)
                .background(AppColors.cardBackground)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.cardBorder, lineWidth: 1))
        }
    }

    private func appendDigit(_ digit: String) {
        guard enteredPin.count < maxPinLength else { return }
        HapticService.shared.impact(.light)
        enteredPin.append(digit)

        if enteredPin.count == maxPinLength {
            verifyEnteredPin()
        }
    }

    private func clearPin() {
        HapticService.shared.selection()
        enteredPin = ""
    }

    private func backspacePin() {
        guard !enteredPin.isEmpty else { return }
        HapticService.shared.selection()
        enteredPin.removeLast()
    }

    private func verifyEnteredPin() {
        Task {
            let success = await viewModel.authenticate(pin: enteredPin)
            if !success {
                isShaking = true
                enteredPin = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isShaking = false
                }
            }
        }
    }

    private func triggerBiometrics() {
        Task {
            let passed = await BiometricAuthService.shared.authenticateWithBiometrics()
            if passed {
                _ = await viewModel.authenticate(pin: viewModel.profile.pin)
            }
        }
    }
}

