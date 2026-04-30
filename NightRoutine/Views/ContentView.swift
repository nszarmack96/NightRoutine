import SwiftUI

struct ContentView: View {
    @AppStorage("nightroutine.onboarded") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            HomeView()
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}

#Preview("Onboarding") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("Tonight") {
    ContentView()
        .preferredColorScheme(.dark)
        .onAppear {
            UserDefaults.standard.set(true, forKey: "nightroutine.onboarded")
        }
}
