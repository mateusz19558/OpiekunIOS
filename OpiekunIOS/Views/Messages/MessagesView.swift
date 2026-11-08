import SwiftUI

public struct MessagesView: View {
    @ObservedObject var viewModel: GuardianViewModel
    @State private var customText: String = ""
    @State private var isSending: Bool = false

    private let presetTemplates = [
        ("📚 Odrób lekcje!", "Odrób lekcje!"),
        ("🍲 Obiad na stole!", "Kończ grę, zaraz obiad na stole!"),
        ("🌙 Pora spać!", "Czas do spania! Za 5 minut komputer zostanie wyłączony."),
        ("🧹 Posprzątaj pokój!", "Wynieś śmieci i posprzątaj pokój!"),
        ("🚗 Zbieraj się!", "Zaraz wychodzimy z domu, kończ grę i ubieraj się."),
        ("🚨 Zejdź natychmiast!", "Proszę natychmiast zejść do salonu!")
    ]

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Explanation
                        VStack(alignment: .leading, spacing: 6) {
                            Text("WYŚLIJ KOMUNIKAT NA EKRAN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)

                            Text("Wiadomość wyświetli się na środku ekranu dziecka jako duże, nieprzegapialne okno modalne wraz z sygnałem dźwiękowym.")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(3)
                        }

                        // Presets Grid
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SZYBKIE SZABLONY WIADOMOŚCI")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(presetTemplates, id: \.0) { item in
                                    Button {
                                        sendDirectMessage(item.1)
                                    } label: {
                                        Text(item.0)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(12)
                                            .background(AppColors.cardBackground)
                                            .cornerRadius(12)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.cardBorder, lineWidth: 1))
                                    }
                                }
                            }
                        }

                        // Custom Message Composer
                        VStack(alignment: .leading, spacing: 10) {
                            Text("WŁASNY KOMUNIKAT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textMuted)

                            VStack(spacing: 8) {
                                TextEditor(text: $customText)
                                    .frame(minHeight: 100)
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(AppColors.inputBackground)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))

                                HStack {
                                    Text("\(customText.count) znaków")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.textMuted)

                                    Spacer()

                                    if !customText.isEmpty {
                                        Button("Wyczyść") {
                                            customText = ""
                                        }
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(AppColors.accentRed)
                                    }
                                }
                            }
                            .modernCard()

                            Button {
                                sendDirectMessage(customText)
                            } label: {
                                HStack {
                                    if isSending {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                        Text("Wyślij na ekran komputera")
                                    }
                                }
                            }
                            .buttonStyle(GlowingButtonStyle(gradient: AppColors.blueGradient))
                            .disabled(customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                        }

                        // Last Sent Message Card
                        if !viewModel.status.lastParentMessage.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("OSTATNIO WYSŁANY KOMUNIKAT:")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textMuted)

                                HStack(spacing: 10) {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .foregroundColor(AppColors.accentBlue)
                                    Text("\"\(viewModel.status.lastParentMessage)\"")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(hex: 0xe2e8f0))
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.cardBorder, lineWidth: 1))
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Wiadomości i Alerty")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sendDirectMessage(_ text: String) {
        guard !text.isEmpty else { return }
        isSending = true
        Task {
            let success = await viewModel.sendMessage(text)
            isSending = false
            if success && text == customText {
                customText = ""
            }
        }
    }
}

