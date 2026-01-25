import SwiftUI

struct TonightView: View {
    // Placeholder data for Phase 0 - will be replaced with real data model
    @State private var steps: [(id: UUID, title: String, isComplete: Bool)] = AppConstants.defaultSteps.map {
        (id: UUID(), title: $0, isComplete: false)
    }

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var allComplete: Bool {
        steps.allSatisfy { $0.isComplete }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()

                if allComplete {
                    // Completion state
                    completionView
                } else {
                    // Checklist
                    checklistView
                }
            }
            .navigationTitle("Wind Down")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Navigate to settings/edit
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }

    // MARK: - Checklist View

    private var checklistView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Date subtitle
                HStack {
                    Text(currentDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 24)

                // Steps list
                VStack(spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        StepRow(
                            title: step.title,
                            isComplete: step.isComplete
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                steps[index].isComplete.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Done for tonight")
                .font(.title)
                .fontWeight(.medium)

            Text("Sleep well")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                // Reset for testing in Phase 0
                withAnimation {
                    for index in steps.indices {
                        steps[index].isComplete = false
                    }
                }
            } label: {
                Text("Reset")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step Row Component

struct StepRow: View {
    let title: String
    let isComplete: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    Circle()
                        .strokeBorder(isComplete ? Color.green : Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isComplete {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }

                // Title
                Text(title)
                    .font(.body)
                    .foregroundStyle(isComplete ? .secondary : .primary)
                    .strikethrough(isComplete, color: .secondary)

                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TonightView()
        .preferredColorScheme(.dark)
}
