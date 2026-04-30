import SwiftUI

struct RoutinePreset: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let steps: [String]
}

extension RoutinePreset {
    static let all: [RoutinePreset] = [
        RoutinePreset(
            name: "Quick",
            subtitle: "5 min · The essentials only",
            icon: "bolt.fill",
            iconColor: .yellow,
            steps: [
                "Brush teeth",
                "Wash face",
                "Set alarm",
                "Lights off"
            ]
        ),
        RoutinePreset(
            name: "Deep Wind Down",
            subtitle: "20 min · Full reset for the mind",
            icon: "moon.stars.fill",
            iconColor: .purple,
            steps: [
                "Skincare",
                "Brush teeth",
                "Journaling",
                "Stretch",
                "No screens",
                "Breathing exercise",
                "Water",
                "Lights off"
            ]
        ),
        RoutinePreset(
            name: "High Discipline",
            subtitle: "Optimized for peak performance",
            icon: "flame.fill",
            iconColor: .orange,
            steps: [
                "Cold shower",
                "Skincare",
                "Brush teeth",
                "Review tomorrow's goals",
                "Journaling",
                "Read (not a screen)",
                "Stretch",
                "Phone in another room",
                "Lights off by 10 PM"
            ]
        ),
        RoutinePreset(
            name: "Mindful",
            subtitle: "Slow down and reset",
            icon: "sparkles",
            iconColor: .cyan,
            steps: [
                "Skincare",
                "Brush teeth",
                "Gratitude list",
                "Meditation",
                "Herbal tea",
                "Dim lights an hour early",
                "Stretch",
                "Lights off"
            ]
        )
    ]
}

struct RoutinePresetSheet: View {
    let onSelect: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
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
                    VStack(spacing: 12) {
                        Text("Choose a starting point — you can edit it after.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)

                        ForEach(RoutinePreset.all) { preset in
                            presetCard(preset)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Routine Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func presetCard(_ preset: RoutinePreset) -> some View {
        Button {
            HapticService.selection()
            onSelect(preset.steps)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: preset.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(preset.iconColor)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(preset.iconColor.opacity(0.15))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(preset.name)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Text(preset.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.25))
                }

                // Step preview
                Text(preset.steps.joined(separator: "  ·  "))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RoutinePresetSheet(onSelect: { _ in })
        .preferredColorScheme(.dark)
}
