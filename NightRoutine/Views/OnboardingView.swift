import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "moon.stars.fill",
            iconColor: .purple,
            title: "Wind Down",
            subtitle: "Your peaceful evening ritual",
            description: "A simple checklist to help you transition from day to night with intention."
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            iconColor: .green,
            title: "One Step at a Time",
            subtitle: "No pressure, just progress",
            description: "Tap through your routine at your own pace. Every small step counts."
        ),
        OnboardingPage(
            icon: "flame.fill",
            iconColor: .orange,
            title: "Build Your Streak",
            subtitle: "Consistency without guilt",
            description: "Track your progress gently. Miss a night? No worries—just start again."
        )
    ]

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars background
            StarsView()

            VStack(spacing: 0) {
                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Continue button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Skip button (only on first pages)
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.bottom, 24)
                } else {
                    Spacer()
                        .frame(height: 44)
                }
            }
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: page.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(page.iconColor)
            }
            .padding(.bottom, 16)

            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            // Subtitle
            Text(page.subtitle)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))

            // Description
            Text(page.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.horizontal)
    }
}

// MARK: - Stars Background

struct StarsView: View {
    @State private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { index in
                    if index < stars.count {
                        Circle()
                            .fill(Color.white)
                            .frame(width: stars[index].size, height: stars[index].size)
                            .opacity(stars[index].opacity)
                            .position(x: stars[index].x, y: stars[index].y)
                    }
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
            }
        }
    }

    private func generateStars(in size: CGSize) {
        stars = (0..<50).map { _ in
            (
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height * 0.6),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.2...0.8)
            )
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
