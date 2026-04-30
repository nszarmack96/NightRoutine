import SwiftUI

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss

    private let history: DailyHistory
    private let streakData: StreakData
    private let isPremium: Bool

    init(persistence: PersistenceService = .shared) {
        self.history = persistence.loadDailyHistory()
        self.streakData = persistence.loadStreakData()
        self.isPremium = persistence.loadPremiumStatus().isPremium
    }

    // MARK: - Calendar State

    @State private var calendarMonth: Date = {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    }()

    // MARK: - Computed Stats (last 7 days)

    private var last7DayKeys: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
                .map { formatter.string(from: $0) }
        }
    }

    private var last7Records: [DailyRecord] {
        last7DayKeys.compactMap { history[$0] }
    }

    /// Nights with at least one step completed or skipped (i.e., the app was opened)
    private var nightsCompleted: Int {
        last7DayKeys.filter { key in
            if let record = history[key] {
                return !record.wasSkipped && record.completedStepIDs.count > 0
                    || streakData.completedDates.contains(key)
            }
            return streakData.completedDates.contains(key)
        }.count
    }

    private var averageCompletion: Double {
        let relevant = last7Records.filter { !$0.wasSkipped && $0.totalSteps > 0 }
        guard !relevant.isEmpty else { return 0 }
        return relevant.map(\.completionPercentage).reduce(0, +) / Double(relevant.count)
    }

    private var mostSkippedStep: String? {
        // Count skips per step title across all history (not just 7 days)
        var skipCounts: [String: Int] = [:]
        for record in history.values where !record.wasSkipped {
            for snapshot in record.stepSnapshots where !record.completedStepIDs.contains(snapshot.id) {
                skipCounts[snapshot.title, default: 0] += 1
            }
        }
        return skipCounts.max(by: { $0.value < $1.value })?.key
    }

    private var longestStreak: Int {
        streakData.currentStreak()
    }

    private var totalCompletedNights: Int {
        streakData.completedDates.count
    }

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

                if history.isEmpty && streakData.completedDates.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            weeklySection
                            historyCalendarSection
                            allTimeSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Your Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Weekly Section

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "calendar", title: "This Week")

            // Nights completed card
            statCard(
                icon: "moon.stars.fill",
                iconColor: .purple,
                label: "Nights completed",
                value: "\(nightsCompleted) of 7"
            )

            // Average completion card
            statCard(
                icon: "chart.bar.fill",
                iconColor: .indigo,
                label: "Average completion",
                value: averageCompletion > 0 ? "\(Int(averageCompletion * 100))%" : "—"
            )

            // 7-day calendar dots
            weekCalendar
        }
    }

    private var weekCalendar: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        return VStack(alignment: .leading, spacing: 10) {
            Text("Last 7 nights")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))

            HStack(spacing: 8) {
                ForEach(Array(last7DayKeys.reversed().enumerated()), id: \.offset) { _, key in
                    let date = formatter.date(from: key) ?? Date()
                    let isCompleted = streakData.completedDates.contains(key)
                    let isFrozen = streakData.frozenDates.contains(key)

                    VStack(spacing: 4) {
                        Text(dayFormatter.string(from: date))
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.4))

                        ZStack {
                            Circle()
                                .fill(
                                    isFrozen ? Color.cyan.opacity(0.3) :
                                    isCompleted ? Color.purple.opacity(0.5) :
                                    Color.white.opacity(0.07)
                                )
                                .frame(width: 32, height: 32)

                            if isFrozen {
                                Image(systemName: "snowflake")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.cyan)
                            } else if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    // MARK: - History Calendar Section

    private var historyCalendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "calendar.badge.clock", title: "History")

            VStack(spacing: 12) {
                // Month navigation
                HStack {
                    Button {
                        calendarMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarMonth) ?? calendarMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(8)
                    }

                    Spacer()

                    Text(monthTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        let next = Calendar.current.date(byAdding: .month, value: 1, to: calendarMonth) ?? calendarMonth
                        // Don't go past current month
                        if next <= Date() {
                            calendarMonth = next
                        }
                    } label: {
                        let next = Calendar.current.date(byAdding: .month, value: 1, to: calendarMonth) ?? calendarMonth
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(next > Date() ? .white.opacity(0.15) : .white.opacity(0.5))
                            .padding(8)
                    }
                }

                // Day-of-week headers
                HStack(spacing: 0) {
                    ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar grid
                calendarGrid
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                    )
            )

            // Legend
            HStack(spacing: 16) {
                legendDot(color: .purple, label: "Completed")
                legendDot(color: .cyan, label: "Freeze used")
                legendDot(color: .white.opacity(0.15), label: "Missed")
            }
            .padding(.horizontal, 4)
        }
    }

    private var calendarGrid: some View {
        let days = calendarDays(for: calendarMonth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let date = day {
                    calendarCell(date: date)
                } else {
                    Color.clear.frame(height: 32)
                }
            }
        }
    }

    private func calendarCell(date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let key = formatter.string(from: date)

        let isCompleted = streakData.completedDates.contains(key)
        let isFrozen = streakData.frozenDates.contains(key)
        let isToday = Calendar.current.isDateInToday(date)
        let isFuture = date > Date()
        let dayNum = Calendar.current.component(.day, from: date)

        return ZStack {
            Circle()
                .fill(
                    isFrozen ? Color.cyan.opacity(0.35) :
                    isCompleted ? Color.purple.opacity(0.6) :
                    isToday ? Color.white.opacity(0.12) :
                    Color.clear
                )

            Text("\(dayNum)")
                .font(.system(size: 12, weight: isToday ? .bold : .regular))
                .foregroundStyle(
                    isFuture ? .white.opacity(0.15) :
                    (isCompleted || isFrozen) ? .white :
                    isToday ? .white.opacity(0.9) :
                    .white.opacity(0.35)
                )
        }
        .frame(height: 32)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: calendarMonth)
    }

    /// Returns an array of optional Dates for the grid — nil fills leading/trailing gaps.
    private func calendarDays(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        let weekday = calendar.component(.weekday, from: firstOfMonth) - 1 // 0 = Sunday
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    // MARK: - All Time Section

    private var allTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "sparkles", title: "All Time")

            statCard(
                icon: "flame.fill",
                iconColor: .orange,
                label: "Current streak",
                value: "\(longestStreak) \(longestStreak == 1 ? "day" : "days")"
            )

            statCard(
                icon: "checkmark.seal.fill",
                iconColor: .green,
                label: "Total nights completed",
                value: "\(totalCompletedNights)"
            )

            if let skipped = mostSkippedStep {
                statCard(
                    icon: "arrow.uturn.left",
                    iconColor: .yellow,
                    label: "Most skipped step",
                    value: skipped
                )
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.purple)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
    }

    private func statCard(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                )

            Text(label)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 14)
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.2))

            Text("No data yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.5))

            Text("Complete your first routine to start seeing insights here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
    }
}

#Preview {
    InsightsView()
        .preferredColorScheme(.dark)
}
