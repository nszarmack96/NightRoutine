import SwiftUI

/// The shareable streak card. Designed at 1080×1080pt so ImageRenderer
/// produces a crisp square image suitable for Instagram, iMessage, etc.
struct StreakCardView: View {
    let streak: Int
    let date: String

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.04, blue: 0.18),
                    Color(red: 0.10, green: 0.06, blue: 0.22),
                    Color(red: 0.04, green: 0.02, blue: 0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft glow behind moon
            Circle()
                .fill(Color.purple.opacity(0.25))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(y: -60)

            VStack(spacing: 0) {
                Spacer()

                // Moon icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 36)

                // Streak number
                Text("\(streak)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text("day streak")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 48)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 1)
                    .padding(.bottom, 36)

                // Date
                Text(date)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 16)

                Spacer()

                // Branding
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.purple.opacity(0.7))
                    Text("Night Routine")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.bottom, 48)
            }
        }
        .frame(width: 1080, height: 1080)
    }

    static var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

#Preview {
    StreakCardView(streak: 14, date: StreakCardView.formattedDate)
        .scaleEffect(0.35)
        .frame(width: 378, height: 378)
        .background(Color.black)
}
