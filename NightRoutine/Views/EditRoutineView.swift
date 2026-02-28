import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditRoutineViewModel()
    @State private var newStepTitle = ""
    @State private var showingResetConfirmation = false
    @State private var showingSettings = false
    @State private var draggingStep: RoutineStep?

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

                        // Settings section
                        settingsSection

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
                    onSave: { newTitle, newNote in
                        viewModel.updateStep(step, newTitle: newTitle, newNote: newNote)
                    }
                )
                .presentationDetents([.height(320)])
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
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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

            Text("Hold and drag to reorder")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))

            VStack(spacing: 8) {
                ForEach(viewModel.steps) { step in
                    DraggableStepRow(
                        step: step,
                        isDragging: draggingStep?.id == step.id,
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
                    .onDrag {
                        self.draggingStep = step
                        return NSItemProvider(object: step.id.uuidString as NSString)
                    }
                    .onDrop(of: [.text], delegate: StepDropDelegate(
                        step: step,
                        steps: $viewModel.steps,
                        draggingStep: $draggingStep,
                        onReorder: { viewModel.saveSteps() }
                    ))
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.bottom, 4)

            Button {
                showingSettings = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.purple)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminders & Settings")
                            .font(.body)
                            .foregroundStyle(.white)
                        Text("Set up nightly notifications")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        VStack(spacing: 16) {
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

// MARK: - Draggable Step Row

struct DraggableStepRow: View {
    let step: RoutineStep
    let isDragging: Bool
    let onToggleEnabled: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))

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
                .fill(isDragging ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isDragging ? Color.purple.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .opacity(isDragging ? 0.6 : 1.0)
        .scaleEffect(isDragging ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
}

// MARK: - Step Drop Delegate

struct StepDropDelegate: DropDelegate {
    let step: RoutineStep
    @Binding var steps: [RoutineStep]
    @Binding var draggingStep: RoutineStep?
    let onReorder: () -> Void

    func performDrop(info: DropInfo) -> Bool {
        draggingStep = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingStep = draggingStep,
              draggingStep.id != step.id,
              let fromIndex = steps.firstIndex(where: { $0.id == draggingStep.id }),
              let toIndex = steps.firstIndex(where: { $0.id == step.id }) else {
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            steps.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }

        // Update sort order
        for (index, _) in steps.enumerated() {
            steps[index].sortOrder = index
        }

        onReorder()
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// MARK: - Editable Step Row (Legacy)

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
    let onSave: (String, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Step title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step Name")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))

                        TextField("Step name", text: $title)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)

                    // Optional personal note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Personal Note")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("(optional)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.3))
                        }

                        TextField("e.g. Use the blue moisturizer", text: $note)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                            .foregroundStyle(.white)

                        Text("Long-press a step during your routine to see its note")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.3))
                    }
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
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        onSave(title, trimmedNote.isEmpty ? nil : trimmedNote)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            title = step.title
            note = step.note ?? ""
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    EditRoutineView()
        .preferredColorScheme(.dark)
}
