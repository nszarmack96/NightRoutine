import SwiftUI

struct TonightView: View {
    @StateObject private var viewModel = TonightViewModel()
    @State private var showingEditRoutine = false

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 17 {
            return "Good evening"
        } else if hour >= 12 {
            return "Good afternoon"
        } else {
            return "Good morning"
        }
    }

    private var progressPercentage: Double {
        guard !viewModel.enabledSteps.isEmpty else { return 0 }
        let completed = viewModel.enabledSteps.filter { viewModel.isStepCompleted($0) }.count
        return Double(completed) / Double(viewModel.enabledSteps.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.12),
                        Color(red: 0.08, green: 0.06, blue: 0.16),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.allComplete {
                    completionView
                } else {
                    checklistView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStreak > 0 {
                        StreakBadge(count: viewModel.currentStreak)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditRoutine = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .sheet(isPresented: $showingEditRoutine, onDismiss: {
                viewModel.loadData()
            }) {
                EditRoutineView()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Checklist View

    private var checklistView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))

                    Text("Wind Down")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(currentDate)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Progress card
                ProgressCard(
                    completedCount: viewModel.enabledSteps.filter { viewModel.isStepCompleted($0) }.count,
                    totalCount: viewModel.enabledSteps.count,
                    percentage: progressPercentage
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Section header
                HStack {
                    Text("Tonight's Routine")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // Steps list
                VStack(spacing: 10) {
                    ForEach(viewModel.enabledSteps) { step in
                        StepRow(
                            title: step.title,
                            isComplete: viewModel.isStepCompleted(step),
                            stepNumber: (viewModel.enabledSteps.firstIndex(of: step) ?? 0) + 1
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleStep(step)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        ZStack {
            // Subtle stars
            StarsView()
                .opacity(0.5)

            VStack(spacing: 20) {
                Spacer()

                // Moon icon with glow
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("Done for tonight")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("Sleep well")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))

                if viewModel.currentStreak > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.currentStreak) day streak")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.top, 8)
                }

                Spacer()

                // Motivational quote
                VStack(spacing: 8) {
                    Text("\"Rest is not idleness.\"")
                        .font(.body)
                        .italic()
                        .foregroundStyle(.white.opacity(0.4))
                    Text("— John Lubbock")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.bottom, 40)

                Button {
                    withAnimation {
                        viewModel.resetTonight()
                    }
                } label: {
                    Text("Reset Routine")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Progress Card

struct ProgressCard: View {
    let completedCount: Int
    let totalCount: Int
    let percentage: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(completedCount) of \(totalCount) complete")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: percentage)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Step Row Component

struct StepRow: View {
    let title: String
    let isComplete: Bool
    let stepNumber: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Step number or checkmark
                ZStack {
                    Circle()
                        .fill(isComplete ? Color.green : Color.white.opacity(0.1))
                        .frame(width: 36, height: 36)

                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                    } else {
                        Text("\(stepNumber)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                // Title
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(isComplete ? .white.opacity(0.4) : .white)
                    .strikethrough(isComplete, color: .white.opacity(0.3))

                Spacer()

                // Chevron indicator
                if !isComplete {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isComplete ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isComplete ? Color.green.opacity(0.3) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
                .foregroundStyle(.orange)
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.15))
        )
    }
}

#Preview {
    TonightView()
        .preferredColorScheme(.dark)
}
