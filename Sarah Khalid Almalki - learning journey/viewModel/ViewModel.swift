//
//  SwiftUIView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//

import SwiftUI
import Combine

@MainActor
class ViewModel: ObservableObject {
    @Published var userGoal: UserGoal
    @Published var isLearned = false
    @Published var isFreezed = false
    @Published var currentWeekOffset = 0
    @Published var showMonthPicker = false
    @Published var selectedMonth = Calendar.current.component(.month, from: Date())
    @Published var selectedYear = Calendar.current.component(.year, from: Date())

    let calendar = Calendar.current

    init(userGoal: UserGoal) {
        self.userGoal = userGoal
    }

    // MARK: - Log & Freeze
    func logAsLearned() {
        guard !isLearned else { return }
        isLearned = true
        userGoal.streak += 1
        userGoal.lastLoggedDate = Date()
    }

    func freezeDay() {
        guard !isFreezed && userGoal.usedFreezes < userGoal.period.freezeLimit else { return }
        isFreezed = true
        userGoal.usedFreezes += 1
    }

    // MARK: - Week Dates
    var weekDates: [Date] {
        guard let startOfWeek = startOfWeekForOffset(currentWeekOffset) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var monthTitle: String {
        guard let firstDay = weekDates.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: firstDay)
    }

    func startOfWeekForOffset(_ offset: Int) -> Date? {
        let today = calendar.startOfDay(for: Date())
        guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today) else { return nil }
        return calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeek.start)
    }

    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // MARK: - Remaining freezes
    var remainingFreezes: Int {
        userGoal.period.freezeLimit - userGoal.usedFreezes
    }
}
