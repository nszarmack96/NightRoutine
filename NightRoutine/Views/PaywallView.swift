import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PaywallViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.3),
                        Color(red: 0.08, green: 0.06, blue: 0.16),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.purchaseSuccessful {
                    successView
                } else {
                    purchaseView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .task {
            await viewModel.loadProducts()
            // If products still empty after retries, auto-trigger AppStore.sync()
            // which either silently authenticates or prompts sign-in
            if viewModel.product == nil {
                await viewModel.signInAndLoad()
            }
        }
    }

    // MARK: - Purchase View

    private var purchaseView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "star.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 24)

            // Title
            Text("Unlock Premium")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            Text("One-time purchase. Yours forever.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.bottom, 32)

            // Features list
            VStack(alignment: .leading, spacing: 16) {
                PremiumFeatureRow(
                    icon: "infinity",
                    title: "Unlimited Steps",
                    description: "Add as many routine steps as you need"
                )

                PremiumFeatureRow(
                    icon: "bell.badge.fill",
                    title: "Custom Reminders",
                    description: "Personalize your notification messages"
                )

                PremiumFeatureRow(
                    icon: "heart.fill",
                    title: "Support Development",
                    description: "Help us build more calming features"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            // Purchase section
            VStack(spacing: 16) {
                // Price button
                Button {
                    Task {
                        await viewModel.purchase()
                    }
                } label: {
                    HStack {
                        if viewModel.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            Text("Processing...")
                                .fontWeight(.semibold)
                        } else if viewModel.isLoading || (viewModel.product == nil) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Loading price...")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.7))
                        } else {
                            Text("Unlock for \(viewModel.priceString)")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: viewModel.product != nil ? [.yellow, .orange] : [.gray.opacity(0.4), .gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(viewModel.product != nil ? .black : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(viewModel.isPurchasing || viewModel.isLoading || viewModel.product == nil)

                // Restore button
                Button {
                    Task {
                        await viewModel.restore()
                    }
                } label: {
                    Text("Restore Purchase")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .disabled(viewModel.isPurchasing)

                // Legal links
                HStack(spacing: 16) {
                    Button("Terms of Service") {
                        UIApplication.shared.open(AppConstants.termsOfServiceURL)
                    }
                    Text("·")
                    Button("Privacy Policy") {
                        UIApplication.shared.open(AppConstants.privacyPolicyURL)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
            }

            Text("Welcome to Premium!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Thank you for your support.\nEnjoy unlimited steps and custom reminders.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Premium Feature Row

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.yellow)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    PaywallView()
        .preferredColorScheme(.dark)
}
