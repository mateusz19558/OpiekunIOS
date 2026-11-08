import SwiftUI

public struct TimeRequestAlertBanner: View {
    @ObservedObject var viewModel: GuardianViewModel
    let request: TimeRequest

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("🔔")
                    .font(.system(size: 20))

                Text("PROŚBA O DODATKOWY CZAS!")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(Color(hex: 0xfef08a))

                Spacer()

                Text(request.formattedMinutes)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(AppColors.accentAmber)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.accentAmber.opacity(0.2))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.status.targetUserName.isEmpty ? "Dziecko" : viewModel.status.targetUserName) prosi o czas:")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                if !request.reason.isEmpty {
                    Text("\"\(request.reason)\"")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: 0xfde68a))
                }
            }

            // Quick actions
            HStack(spacing: 8) {
                Button {
                    Task {
                        await viewModel.respondToTimeRequest(id: request.id, approved: true, minutes: 15)
                    }
                } label: {
                    Text("+15 min")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.accentGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.accentGreen.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.accentGreen.opacity(0.4), lineWidth: 1))
                }

                Button {
                    Task {
                        await viewModel.respondToTimeRequest(id: request.id, approved: true, minutes: 30)
                    }
                } label: {
                    Text("+30 min")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Color(hex: 0xa7f3d0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.accentGreen.opacity(0.25))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.accentGreen.opacity(0.6), lineWidth: 1))
                }

                Button {
                    Task {
                        await viewModel.respondToTimeRequest(id: request.id, approved: false)
                    }
                } label: {
                    Text("Odrzuć")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: 0xfca5a5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.accentRed.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.accentRed.opacity(0.4), lineWidth: 1))
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x854d0e).opacity(0.4), Color(hex: 0x713f12).opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.accentAmber, lineWidth: 1.5))
        .shadow(color: AppColors.accentAmber.opacity(0.25), radius: 10, y: 4)
    }
}

