// CalendarProgressView.swift
import SwiftUI

struct CalendarProgressView: View {
    @ObservedObject var viewModel: ViewModel
    private let calendar = Calendar.current

    private var monthDate: Date {
        var comps = DateComponents()
        comps.year = viewModel.selectedYear
        comps.month = viewModel.selectedMonth
        comps.day = 1
        return calendar.date(from: comps) ?? Date()
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
    }

    private var firstWeekdayOffset: Int {
        // Shift so weeks start on Sunday (1) -> 0 offset
        let weekday = calendar.component(.weekday, from: monthDate) // 1...7
        return weekday - 1
    }

    private var monthTitle: String {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df.string(from: monthDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header: Month selector and title
            HStack {
                Button {
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }

                Spacer()

                Text(monthTitle)
                    .font(.title3.bold())

                Spacer()

                Button {
                    shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // Weekday headers
            let symbols = Calendar.current.shortWeekdaySymbols // Sun Mon Tue ...
            HStack {
                ForEach(symbols, id: \.self) { s in
                    Text(s)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                // Empty leading cells for first week offset
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 40)
                }

                // Actual days
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateFor(day: day)
                    DayCell(date: date, viewModel: viewModel)
                }
            }
            .padding(.horizontal)

            // Legend / Counts
            legend

            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shiftMonth(by delta: Int) {
        var comps = DateComponents()
        comps.month = delta
        if let newDate = calendar.date(byAdding: comps, to: monthDate) {
            viewModel.selectedYear = calendar.component(.year, from: newDate)
            viewModel.selectedMonth = calendar.component(.month, from: newDate)
        }
    }

    private func dateFor(day: Int) -> Date {
        var comps = DateComponents()
        comps.year = viewModel.selectedYear
        comps.month = viewModel.selectedMonth
        comps.day = day
        return calendar.date(from: comps) ?? Date()
    }

    private var legend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle().fill(Color.orange).frame(width: 10, height: 10)
                Text("Today (no activity)").font(.caption).foregroundColor(.gray)
            }
            HStack(spacing: 6) {
                Circle().fill(Color.orange.opacity(0.3)).frame(width: 10, height: 10)
                Text("Learned").font(.caption).foregroundColor(.gray)
            }
            HStack(spacing: 6) {
                Circle().fill(Color.blue.opacity(0.3)).frame(width: 10, height: 10)
                Text("Freezed").font(.caption).foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DayCell: View {
    let date: Date
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        let isToday = viewModel.isToday(date)
        let learned = viewModel.isLearned(date)
        let freezed = viewModel.isFreezed(date)

        ZStack {
            // New precedence: Learned > Freezed > Today > Nothing
            if learned {
                Circle().fill(Color.orange.opacity(0.3))
            } else if freezed {
                Circle().fill(Color.blue.opacity(0.3))
            } else if isToday {
                Circle().fill(Color.orange)
            } else {
                Circle().stroke(Color.gray.opacity(0.15), lineWidth: 1)
            }

            Text(dayString(date))
                .font(.subheadline)
                .foregroundColor(foregroundColor(isToday: isToday, learned: learned, freezed: freezed))
        }
        .frame(height: 40)
        .contentShape(Rectangle())
    }

    private func dayString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }

    private func foregroundColor(isToday: Bool, learned: Bool, freezed: Bool) -> Color {
        // Match precedence: if learned/freezed, use their colors; if only today, white text
        if learned { return .orange }
        if freezed { return .blue }
        if isToday { return .white }
        return .primary
    }
}

#Preview {
    let goal = UserGoal(text: "Swift", period: .month)
    let vm = ViewModel(userGoal: goal)
    NavigationStack {
        CalendarProgressView(viewModel: vm)
    }
    .preferredColorScheme(.dark)
}
