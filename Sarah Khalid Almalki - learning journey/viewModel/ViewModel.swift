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
    @Published var currentWeekOffset = 0
    @Published var showMonthPicker = false
    @Published var selectedMonth = Calendar.current.component(.month, from: Date())
    @Published var selectedYear = Calendar.current.component(.year, from: Date())

    let calendar = Calendar.current

    init(userGoal: UserGoal) {
        self.userGoal = userGoal
        // Defer any mutations/publishes to after the first render cycle
        Task { @MainActor in
            loadProgress()
            checkForStreakBreak()
            checkPeriodReset()
        }
    }

    var streakTarget: Int {
        switch userGoal.period {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }

    var remainingFreezes: Int {
        userGoal.period.freezeLimit - userGoal.freezedDates.count
    }

    var isLearnedToday: Bool {
        !userGoal.learnedDates.isDisjoint(with: [Calendar.current.startOfDay(for: Date())])
    }

    var isFreezedToday: Bool {
        !userGoal.freezedDates.isDisjoint(with: [Calendar.current.startOfDay(for: Date())])
    }

    var currentStreak: Int {
        let sortedDates = userGoal.learnedDates.sorted()
        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())

        while sortedDates.contains(day) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        return streak
    }

    func checkForStreakBreak() {
        let now = Date()
        let allActivityDates = userGoal.learnedDates.union(userGoal.freezedDates)
        guard let lastActivity = allActivityDates.max() else { return }
        let timeElapsed = now.timeIntervalSince(lastActivity)
        let thirtyTwoHours: TimeInterval = 32 * 60 * 60
        if timeElapsed >= thirtyTwoHours {
            resetGoalData()
        }
    }

    private func resetGoalData() {
        userGoal.streak = 0
        userGoal.lastLoggedDate = nil
        userGoal.usedFreezes = 0
        userGoal.learnedDates = []
        userGoal.freezedDates = []
        userGoal.save()
        // No manual objectWillChange.send(); @Published handles publishing
    }

    // Public intent for "Start the same goal again" in CompletionView
    func resetForSameGoal() {
        // Keep text and period; reset progress
        resetGoalData()
        saveProgress()
    }

    // Public intent for "Set a New Goal" — clear persisted progress so a new goal starts fresh
    func clearSavedProgress() {
        // Clear our own saved progress store
        UserDefaults.standard.removeObject(forKey: "savedUserGoal")
        // Also reset the in-memory goal data so UI updates immediately
        resetGoalData()
    }

    func checkPeriodReset() {
        let savedPeriod = UserDefaults.standard.string(forKey: "savedPeriod") ?? userGoal.period.rawValue
        if savedPeriod != userGoal.period.rawValue {
            // Defer mutation to avoid publishing during view updates
            Task { @MainActor in
                self.userGoal.usedFreezes = 0
                UserDefaults.standard.set(self.userGoal.period.rawValue, forKey: "savedPeriod")
            }
        }
    }

    func logAsLearned() {
        checkForStreakBreak()
        let today = Calendar.current.startOfDay(for: Date())
        guard !isLearnedToday, !isFreezedToday else { return }
        userGoal.learnedDates.insert(today)
        userGoal.lastLoggedDate = today
        userGoal.streak += 1
        saveProgress()
        // No manual objectWillChange.send()
    }

    func freezeDay() {
        checkForStreakBreak()
        let today = Calendar.current.startOfDay(for: Date())
        guard !isFreezedToday, !isLearnedToday else { return }
        guard userGoal.freezedDates.count < userGoal.period.freezeLimit else { return }
        userGoal.freezedDates.insert(today)
        userGoal.usedFreezes += 1
        saveProgress()
        // No manual objectWillChange.send()
    }

    var currentWeekStartDate: Date {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: startOfWeek)!
    }

    var weekDates: [Date] {
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentWeekStartDate)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentWeekStartDate)
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

    func isLearned(_ date: Date) -> Bool {
        userGoal.learnedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    func isFreezed(_ date: Date) -> Bool {
        userGoal.freezedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    fileprivate struct CodableUserGoal: Codable {
        var text: String
        var period: String
        var lastLoggedDate: Date?
        var learnedDates: [Date]
        var freezedDates: [Date]
    }

    private func userGoalToCodable() -> CodableUserGoal {
        CodableUserGoal(
            text: userGoal.text,
            period: userGoal.period.rawValue,
            lastLoggedDate: userGoal.lastLoggedDate,
            learnedDates: Array(userGoal.learnedDates),
            freezedDates: Array(userGoal.freezedDates)
        )
    }

    private func restoreUserGoal(from data: CodableUserGoal) {
        // Perform after current init cycle finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.userGoal.text = data.text
            self.userGoal.period = UserGoal.Period(rawValue: data.period) ?? .week
            self.userGoal.lastLoggedDate = data.lastLoggedDate
            self.userGoal.learnedDates = Set(data.learnedDates)
            self.userGoal.freezedDates = Set(data.freezedDates)
        }
    }

    private func saveProgress() {
        let codable = userGoalToCodable()
        if let encoded = try? JSONEncoder().encode(codable) {
            UserDefaults.standard.set(encoded, forKey: "savedUserGoal")
        }
    }

    private func loadProgress() {
        guard let savedData = UserDefaults.standard.data(forKey: "savedUserGoal") else { return }
        if let decoded = try? JSONDecoder().decode(CodableUserGoal.self, from: savedData) {
            restoreUserGoal(from: decoded)
        }
    }
}

extension UserGoal.Period {
    var freezeLimit: Int {
        switch self {
        case .week:
            return 2
        case .month:
            return 8
        case .year:
            return 96
        }
    }
}

/*class CalendarViewModel: ObservableObject {
    @Published var currentWeekOffset: Int = 0
    

    // helper (optional) to check if a date is today (useful for highlighting)
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue ...
        return formatter.string(from: date)
    }

    func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}*/
