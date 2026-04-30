import SwiftUI

struct TonightView: View {
    @StateObject private var viewModel = TonightViewModel()
    @State private var showingEditRoutine = false
    @State private var previouslyComplete = false
    @State private var showingStreakProtection = false
    @State private var streakFreezeUsed = false
    @State private var showingFocusedRoutine = false
    @State private var shareImage: UIImage? = nil
    @State private var showingShareSheet = false
    @State private var showingInsights = false

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

            if viewModel.showCompletion {
                completionView
            } else {
                checklistView
            }

            // Quiet Mode overlay - dims the screen slightly
            if viewModel.settings.quietModeEnabled {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.currentStreak > 0 {
                    Button {
                        showingInsights = true
                    } label: {
                        StreakBadge(count: viewModel.currentStreak)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("View insights for \(viewModel.currentStreak) day streak")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditRoutine = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .accessibilityLabel("Edit routine settings")
            }
        }
        .sheet(isPresented: $showingEditRoutine, onDismiss: {
            viewModel.loadData()
        }) {
            EditRoutineView()
        }
        .sheet(isPresented: $showingInsights) {
            InsightsView()
        }
        .fullScreenCover(isPresented: $showingFocusedRoutine) {
            FocusedRoutineView(
                steps: viewModel.enabledSteps,
                onComplete: { completedIDs in
                    // Apply completions from focused mode back to the main view model
                    for step in viewModel.enabledSteps {
                        let shouldBeComplete = completedIDs.contains(step.id)
                        let isCurrentlyComplete = viewModel.isStepCompleted(step)
                        if shouldBeComplete != isCurrentlyComplete {
                            viewModel.toggleStep(step)
                        }
                    }
                    if viewModel.hapticsEnabled {
                        HapticService.routineComplete()
                    }
                    previouslyComplete = viewModel.allComplete
                },
                onDismiss: {}
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(image: image)
            }
        }
        .sheet(isPresented: $showingStreakProtection) {
            StreakProtectionSheet(
                streak: viewModel.currentStreak,
                freezesRemaining: viewModel.freezesRemainingThisWeek,
                onUseFreeze: {
                    viewModel.useStreakFreeze()
                    streakFreezeUsed = true
                    showingStreakProtection = false
                },
                onDismiss: {
                    showingStreakProtection = false
                }
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadData()
            // Show streak protection prompt if streak is at risk and freeze is available
            if viewModel.streakAtRisk && viewModel.canUseStreakFreeze && !streakFreezeUsed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingStreakProtection = true
                }
            }
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        Button {
            withAnimation {
                viewModel.skipWithoutGuilt()
            }
            if viewModel.hapticsEnabled {
                HapticService.selection()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "moon.zzz")
                    .font(.system(size: 14))
                Text("Not tonight — and that's okay")
                    .font(.subheadline)
            }
            .foregroundStyle(.white.opacity(0.4))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .accessibilityLabel("Skip tonight's routine")
        .accessibilityHint("End the routine early without affecting your streak")
    }

    // MARK: - Checklist View

    private var checklistView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // App branding header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .indigo.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Night Routine")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Text(currentDate)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Greeting section
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))

                    Text("Time to Wind Down")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Welcome message for new users (no progress yet today)
                if viewModel.currentStreak == 0 && progressPercentage == 0 {
                    welcomeCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }

                // Progress card
                ProgressCard(
                    completedCount: viewModel.enabledSteps.filter { viewModel.isStepCompleted($0) }.count,
                    totalCount: viewModel.enabledSteps.count,
                    percentage: progressPercentage
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Section header + Start Routine button
                HStack {
                    Text("Tonight's Routine")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Button {
                        HapticService.selection()
                        showingFocusedRoutine = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("Start")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.4), .indigo.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .accessibilityLabel("Start focused routine mode")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // Steps list
                VStack(spacing: 10) {
                    ForEach(viewModel.enabledSteps) { step in
                        StepRowWithNote(
                            step: step,
                            isComplete: viewModel.isStepCompleted(step),
                            stepNumber: (viewModel.enabledSteps.firstIndex(of: step) ?? 0) + 1
                        ) {
                            let wasComplete = viewModel.isStepCompleted(step)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleStep(step)
                            }
                            // Haptic feedback (respects Quiet Mode)
                            if viewModel.hapticsEnabled {
                                if wasComplete {
                                    HapticService.stepToggle()
                                } else {
                                    HapticService.stepComplete()
                                }
                            }
                            // Check if routine just completed
                            if viewModel.allComplete && !previouslyComplete {
                                if viewModel.hapticsEnabled {
                                    HapticService.routineComplete()
                                }
                            }
                            previouslyComplete = viewModel.allComplete
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Skip Without Guilt button
                skipButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Welcome Card

    private var welcomeCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(.purple)
                Text("Welcome to your wind-down ritual")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Spacer()
            }

            Text("Check off each step as you go. Build a streak by completing your routine each night.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.15), .indigo.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Completion View

    private var completionView: some View {
        let quote = viewModel.wasSkipped
            ? QuoteService.skipQuote()
            : QuoteService.randomQuote(for: viewModel.settings.quoteTheme)

        return ZStack {
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

                    Image(systemName: viewModel.wasSkipped ? "moon.zzz.fill" : "moon.stars.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: viewModel.wasSkipped ? [.blue, .indigo] : [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                // Different messaging for skip vs complete
                Text(viewModel.wasSkipped ? "Rest easy" : "Done for tonight")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(viewModel.wasSkipped ? "Tomorrow is a new day" : "Sleep well")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))

                // Only show streak for full completion
                if !viewModel.wasSkipped && viewModel.currentStreak > 0 {
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

                // Show freeze badge if streak was saved with a freeze
                if streakFreezeUsed {
                    HStack(spacing: 6) {
                        Image(systemName: "snowflake")
                            .foregroundStyle(.cyan)
                        Text("Streak saved with a freeze")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .font(.caption)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.1))
                    )
                }

                // Share streak card — only for full completions with a streak
                if !viewModel.wasSkipped && viewModel.currentStreak > 0 {
                    Button {
                        shareStreakCard()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Share your streak")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                    }
                    .accessibilityLabel("Share your \(viewModel.currentStreak) day streak")
                }

                Spacer()

                // Tomorrow preview message
                Text(QuoteService.tomorrowMessage())
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // Themed quote
                VStack(spacing: 8) {
                    Text("\"\(quote.quote)\"")
                        .font(.body)
                        .italic()
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                    Text("— \(quote.author)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)

                Button {
                    withAnimation {
                        viewModel.resetTonight()
                    }
                    if viewModel.hapticsEnabled {
                        HapticService.selection()
                    }
                    previouslyComplete = false
                } label: {
                    Text("Reset Routine")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .accessibilityLabel("Reset tonight's routine")
                .accessibilityHint("Uncheck all completed steps")
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Share Streak Card

    private func shareStreakCard() {
        Task { @MainActor in
            let card = StreakCardView(
                streak: viewModel.currentStreak,
                date: StreakCardView.formattedDate
            )
            let renderer = ImageRenderer(content: card)
            renderer.scale = 1 // card is already 1080pt; 1x gives 1080px output
            renderer.proposedSize = .init(width: 1080, height: 1080)

            guard let image = renderer.uiImage else { return }
            shareImage = image
            showingShareSheet = true

            if viewModel.hapticsEnabled {
                HapticService.selection()
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
            .accessibilityHidden(true)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: \(completedCount) of \(totalCount) steps complete, \(Int(percentage * 100)) percent")
    }
}

// MARK: - Step Row With Note Component

struct StepRowWithNote: View {
    let step: RoutineStep
    let isComplete: Bool
    let stepNumber: Int
    let onTap: () -> Void

    @State private var showingNote = false

    private var hasNote: Bool {
        guard let note = step.note else { return false }
        return !note.isEmpty
    }

    private var circleColor: Color {
        isComplete ? Color.green : Color.white.opacity(0.1)
    }

    private var borderColor: Color {
        isComplete ? Color.green.opacity(0.3) : Color.white.opacity(0.08)
    }

    private var fillColor: Color {
        isComplete ? Color.green.opacity(0.1) : Color.white.opacity(0.05)
    }

    private var titleColor: Color {
        isComplete ? Color.white.opacity(0.4) : Color.white
    }

    private var accessibilityHintText: String {
        let noteHint = hasNote ? "Long press to see note. " : ""
        let tapHint = isComplete ? "Double tap to unmark" : "Double tap to mark as complete"
        return noteHint + tapHint
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                rowContent
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        if hasNote {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingNote.toggle()
                            }
                        }
                    }
            )
        }
        .accessibilityLabel("\(step.title), step \(stepNumber)")
        .accessibilityValue(isComplete ? "completed" : "not completed")
        .accessibilityHint(accessibilityHintText)
    }

    private var rowContent: some View {
        HStack(spacing: 16) {
            stepIndicator
            titleSection
            Spacer()
            trailingIcons
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(rowBackground)
    }

    private var stepIndicator: some View {
        ZStack {
            Circle()
                .fill(circleColor)
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
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(step.title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(titleColor)
                .strikethrough(isComplete, color: .white.opacity(0.3))

            if showingNote, let note = step.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private var trailingIcons: some View {
        if hasNote && !showingNote {
            Image(systemName: "note.text")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.25))
        }

        if !isComplete {
            Image(systemName: "circle")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.2))
        }
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }
}

// MARK: - Step Row Component (Legacy)

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
        .accessibilityLabel("\(title), step \(stepNumber)")
        .accessibilityValue(isComplete ? "completed" : "not completed")
        .accessibilityHint(isComplete ? "Double tap to unmark" : "Double tap to mark as complete")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(count) day streak")
    }
}

#Preview {
    TonightView()
        .preferredColorScheme(.dark)
}
