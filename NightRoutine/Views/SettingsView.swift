import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingTimePicker = false

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
                        // Reminder Section
                        reminderSection

                        // About Section
                        aboutSection
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Notifications Disabled", isPresented: $viewModel.permissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To receive nightly reminders, please enable notifications in Settings.")
            }
            .sheet(isPresented: $showingTimePicker) {
                TimePickerSheet(
                    selectedTime: Binding(
                        get: { viewModel.reminderTime },
                        set: { viewModel.reminderTime = $0 }
                    )
                )
                .presentationDetents([.height(280)])
            }
        }
    }

    // MARK: - Reminder Section

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.purple)
                Text("Nightly Reminder")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            // Enable/Disable Toggle
            SettingsRow(
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Reminder",
                subtitle: viewModel.settings.reminderEnabled ? "On" : "Off"
            ) {
                Toggle("", isOn: Binding(
                    get: { viewModel.settings.reminderEnabled },
                    set: { _ in
                        Task {
                            await viewModel.toggleReminder()
                        }
                    }
                ))
                .labelsHidden()
                .tint(.purple)
            }

            if viewModel.settings.reminderEnabled {
                // Time Picker Row
                SettingsRow(
                    icon: "clock.fill",
                    iconColor: .blue,
                    title: "Reminder Time",
                    subtitle: viewModel.settings.reminderTimeFormatted
                ) {
                    Button {
                        showingTimePicker = true
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                // Custom Message Row (Premium Only)
                if viewModel.canCustomizeMessage {
                    customMessageSection
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Custom reminder messages available with Premium")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange.opacity(0.8))
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var customMessageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Message")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            TextField(
                "Your night routine is waiting...",
                text: Binding(
                    get: { viewModel.settings.reminderMessage ?? "" },
                    set: { viewModel.updateReminderMessage($0) }
                )
            )
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
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.gray)
                Text("About")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            SettingsRow(
                icon: "doc.text.fill",
                iconColor: .gray,
                title: "Privacy Policy",
                subtitle: nil
            ) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
            }

            SettingsRow(
                icon: "envelope.fill",
                iconColor: .gray,
                title: "Support",
                subtitle: nil
            ) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
            }

            // Version info
            HStack {
                Spacer()
                Text("Night Routine v0.3.0")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Settings Row Component

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                )

            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Spacer()

            trailing
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
}

// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    DatePicker(
                        "Reminder Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
