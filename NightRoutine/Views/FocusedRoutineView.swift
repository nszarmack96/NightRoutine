import SwiftUI

struct FocusedRoutineView: View {
    let steps: [RoutineStep]
    let onComplete: (Set<UUID>) -> Void
    let onDismiss: () -> Void

    @State private var currentIndex: Int = 0
    @State private var completedIDs: Set<UUID> = []
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false
    @Environment(\.dismiss) private var dismiss

    private var currentStep: RoutineStep? {
        guard currentIndex < steps.count else { return nil }
        return steps[currentIndex]
    }

    private var isLastStep: Bool {
        currentIndex == steps.count - 1
    }

    private var isCurrentComplete: Bool {
        guard let step = currentStep else { return false }
        return completedIDs.contains(step.id)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.14),
                    Color(red: 0.08, green: 0.05, blue: 0.18),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)

                // Step progress dots
                progressDots
                    .padding(.bottom, 40)

                Spacer()

                // Step card
                if let step = currentStep {
                    stepCard(step)
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Only allow left swipe to advance, right swipe to go back
                                    if value.translation.width < 0 || currentIndex > 0 {
                                        dragOffset = value.translation.width * 0.4
                                    }
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 60
                                    if value.translation.width < -threshold && isCurrentComplete {
                                        advance()
                                    } else if value.translation.width > threshold && currentIndex > 0 {
                                        goBack()
                                    } else {
                                        let _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }

                Spacer()

                // Action button
                actionButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .statusBarHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                HapticService.selection()
                onDismiss()
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Exit")
                        .font(.subheadline)
                }
                .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Text("\(currentIndex + 1) of \(steps.count)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<steps.count, id: \.self) { index in
                let isDone = completedIDs.contains(steps[index].id)
                let isCurrent = index == currentIndex
                Capsule()
                    .fill(
                        isDone ? Color.purple :
                        isCurrent ? Color.white.opacity(0.6) :
                        Color.white.opacity(0.15)
                    )
                    .frame(width: isCurrent ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentIndex)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: completedIDs)
            }
        }
    }

    // MARK: - Step Card

    private func stepCard(_ step: RoutineStep) -> some View {
        let isComplete = completedIDs.contains(step.id)

        return VStack(spacing: 20) {
            // Step icon / completion indicator
            ZStack {
                Circle()
                    .fill(
                        isComplete
                            ? LinearGradient(colors: [.green.opacity(0.3), .teal.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.purple.opacity(0.2), .indigo.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.green)
                } else {
                    Text("\(currentIndex + 1)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isComplete)

            // Step title
            Text(step.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Note if present
            if let note = step.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        VStack(spacing: 12) {
            if !isCurrentComplete {
                // Mark done
                Button {
                    markCurrentDone()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                        Text("Done")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            } else {
                // Advance / finish
                Button {
                    if isLastStep {
                        finishRoutine()
                    } else {
                        advance()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(isLastStep ? "Finish Routine" : "Next Step")
                            .font(.body)
                            .fontWeight(.semibold)
                        Image(systemName: isLastStep ? "moon.stars.fill" : "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: isLastStep ? [.purple, .indigo] : [.white.opacity(0.1), .white.opacity(0.08)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }

            // Skip this step
            Button {
                HapticService.selection()
                if isLastStep {
                    finishRoutine()
                } else {
                    advanceWithoutCompletion()
                }
            } label: {
                Text(isLastStep ? "Finish without this step" : "Skip this step")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Actions

    private func markCurrentDone() {
        guard let step = currentStep else { return }
        HapticService.stepComplete()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            completedIDs.insert(step.id)
        }
    }

    private func advance() {
        guard currentIndex < steps.count - 1 else { return }
        HapticService.selection()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            currentIndex += 1
        }
    }

    private func advanceWithoutCompletion() {
        guard currentIndex < steps.count - 1 else { return }
        HapticService.selection()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            currentIndex += 1
        }
    }

    private func goBack() {
        guard currentIndex > 0 else { return }
        HapticService.selection()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            currentIndex -= 1
        }
    }

    private func finishRoutine() {
        HapticService.routineComplete()
        onComplete(completedIDs)
        dismiss()
    }
}

#Preview {
    FocusedRoutineView(
        steps: RoutineStep.defaultSteps(),
        onComplete: { _ in },
        onDismiss: {}
    )
}
