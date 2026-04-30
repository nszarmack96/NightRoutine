import SwiftUI

struct StreakProtectionSheet: View {
    let streak: Int
    let freezesRemaining: Int
    let onUseFreeze: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.05, blue: 0.15),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 32)

                // Flame icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 88, height: 88)
                        .blur(radius: 16)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .padding(.bottom, 24)

                Text("Save Your Streak")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text("You missed last night, but your \(streak)-day streak doesn't have to end.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)

                // Freeze info card
                HStack(spacing: 16) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 20))
                        .foregroundStyle(.cyan)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Streak Freeze")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Text("\(freezesRemaining) of \(AppConstants.maxFreezesPerWeek) remaining this week")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.cyan.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // Use freeze button
                Button {
                    HapticService.routineComplete()
                    onUseFreeze()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "snowflake")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Use a Freeze")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.7), .blue.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // Dismiss
                Button {
                    onDismiss()
                } label: {
                    Text("Let the streak go")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.vertical, 12)
                }
                .padding(.bottom, 16)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            StreakProtectionSheet(
                streak: 12,
                freezesRemaining: 2,
                onUseFreeze: {},
                onDismiss: {}
            )
        }
}
