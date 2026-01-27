import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditRoutineViewModel()
    @State private var newStepTitle = ""
    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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

                ScrollView {
                    VStack(spacing: 24) {
                        // Add new step section
                        addStepSection

                        // Steps list section
                        stepsListSection

                        // Reset to defaults
                        resetSection
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $viewModel.editingStep) { step in
                EditStepSheet(
                    step: step,
                    onSave: { newTitle in
                        viewModel.updateStepTitle(step, newTitle: newTitle)
                    }
                )
                .presentationDetents([.height(200)])
            }
            .alert("Reset to Defaults?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            } message: {
                Text("This will replace your current routine with the default steps.")
            }
            .sheet(isPresented: $viewModel.showingPaywall) {
                PaywallPlaceholderView()
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Add Step Section

    private var addStepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add New Step")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 12) {
                TextField("Step name", text: $newStepTitle)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                    )
                    .foregroundStyle(.white)

                Button {
                    viewModel.addStep(title: newStepTitle)
                    newStepTitle = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            newStepTitle.isEmpty ? .gray : .green
                        )
                }
                .disabled(newStepTitle.isEmpty)
            }

            if !viewModel.canAddMoreSteps {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text(viewModel.stepLimitMessage)
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Steps List Section

    private var stepsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Steps")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(viewModel.steps.count) steps")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Text("Drag to reorder • Swipe to delete")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))

            LazyVStack(spacing: 8) {
                ForEach(viewModel.steps) { step in
                    EditableStepRow(
                        step: step,
                        onToggleEnabled: {
                            viewModel.toggleStepEnabled(step)
                        },
                        onEdit: {
                            viewModel.editingStep = step
                        },
                        onDelete: {
                            withAnimation {
                                viewModel.deleteStep(step)
                            }
                        }
                    )
                }
                .onMove { source, destination in
                    viewModel.moveSteps(from: source, to: destination)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.white.opacity(0.1))

            Button {
                showingResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Default Steps")
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - Editable Step Row

struct EditableStepRow: View {
    let step: RoutineStep
    let onToggleEnabled: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.3))

            // Enable/disable toggle
            Button(action: onToggleEnabled) {
                Image(systemName: step.isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(step.isEnabled ? .green : .white.opacity(0.3))
            }

            // Step title
            Text(step.title)
                .font(.body)
                .foregroundStyle(step.isEnabled ? .white : .white.opacity(0.4))
                .strikethrough(!step.isEnabled, color: .white.opacity(0.3))
                .lineLimit(1)

            Spacer()

            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(8)
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(.red.opacity(0.7))
                    .padding(8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Edit Step Sheet

struct EditStepSheet: View {
    let step: RoutineStep
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Step name", text: $title)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(title)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            title = step.title
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Paywall Placeholder

struct PaywallPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.purple.opacity(0.3), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.yellow)

                    Text("Unlock Premium")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "infinity", text: "Unlimited steps")
                        FeatureRow(icon: "bell.badge", text: "Custom reminder messages")
                        FeatureRow(icon: "paintpalette", text: "Extra themes")
                    }
                    .padding(.horizontal, 40)

                    Text("Coming soon in Phase 7!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.yellow)
                .frame(width: 24)
            Text(text)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    EditRoutineView()
        .preferredColorScheme(.dark)
}
