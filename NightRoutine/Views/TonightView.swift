import SwiftUI

struct TonightView: View {
    @StateObject private var viewModel = TonightViewModel()

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if viewModel.allComplete {
                    completionView
                } else {
                    checklistView
                }
            }
            .navigationTitle("Wind Down")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStreak > 0 {
                        StreakBadge(count: viewModel.currentStreak)
                    }
                }
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
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Checklist View

    private var checklistView: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text(currentDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 24)

                VStack(spacing: 12) {
                    ForEach(viewModel.enabledSteps) { step in
                        StepRow(
                            title: step.title,
                            isComplete: viewModel.isStepCompleted(step)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleStep(step)
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

            if viewModel.currentStreak > 0 {
                Text("\(viewModel.currentStreak) day streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            Spacer()

            Button {
                withAnimation {
                    viewModel.resetTonight()
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
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TonightView()
        .preferredColorScheme(.dark)
}
