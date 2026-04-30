import SwiftUI

struct HomeView: View {
    @State private var showingTonightView = false
    @State private var streak: Int = 0
    @State private var completedTonight: Bool = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 17 { return "Good evening" }
        if hour >= 12 { return "Good afternoon" }
        return "Good morning"
    }

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.08, green: 0.06, blue: 0.18),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                StarsView()
                    .opacity(0.6)

                VStack(spacing: 0) {
                    Spacer()

                    // App icon / branding
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .indigo.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)

                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.bottom, 28)

                    // Greeting + date
                    VStack(spacing: 8) {
                        Text(greeting)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.5))

                        Text("Night Routine")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text(currentDate)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.bottom, 36)

                    // Streak badge (if active)
                    if streak > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(streak) day streak")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.orange.opacity(0.25), lineWidth: 1)
                                )
                        )
                        .padding(.bottom, 48)
                    } else {
                        Spacer()
                            .frame(height: 48)
                    }

                    Spacer()

                    // CTA button
                    Button {
                        showingTonightView = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: completedTonight ? "checkmark.circle.fill" : "moon.stars.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text(completedTonight ? "Routine Complete" : "Begin Tonight's Routine")
                                .font(.headline)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: completedTonight ? [.green, .mint] : [.purple, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    Text("Tap to open your checklist")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.25))
                        .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $showingTonightView) {
                TonightView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            loadState()
        }
    }

    private func loadState() {
        let persistence = PersistenceService.shared
        let streakData = persistence.loadStreakData()
        streak = streakData.currentStreak()
        completedTonight = streakData.completedDates.contains(RoutineState.todayKey())
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
