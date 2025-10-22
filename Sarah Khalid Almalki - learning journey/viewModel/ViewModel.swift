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
        loadProgress()
        // Update today's status
        isLearned = isLearnedToday
        isFreezed = isFreezedToday
        checkPeriodReset()
        checkAndResetForNewDay()
    }

    // MARK: - Computed properties
    var remainingFreezes: Int {
        userGoal.period.freezeLimit - usedFreezesForPeriod
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

    var usedFreezesForPeriod: Int {
        userGoal.freezedDates.filter { date in
            switch userGoal.period {
            case .week:
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month:
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
            case .year:
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year)
            }
        }.count
    }

    var isLearnedToday: Bool {
        userGoal.learnedDates.contains { Calendar.current.isDateInToday($0) }
    }

    var isFreezedToday: Bool {
        userGoal.freezedDates.contains { Calendar.current.isDateInToday($0) }
    }

    // MARK: - Period handling
    func checkPeriodReset() {
        let savedPeriod = UserDefaults.standard.string(forKey: "savedPeriod") ?? userGoal.period.rawValue
        if savedPeriod != userGoal.period.rawValue {
            userGoal.usedFreezes = 0
            UserDefaults.standard.set(userGoal.period.rawValue, forKey: "savedPeriod")
        }
    }

    func checkAndResetForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = userGoal.lastLoggedDate {
            if !Calendar.current.isDate(last, inSameDayAs: today) {
                isLearned = false
                isFreezed = false
            }
        } else {
            isLearned = false
            isFreezed = false
        }
    }

    func changePeriod(to newPeriod: UserGoal.Period) {
        userGoal.period = newPeriod
        saveProgress()
    }

    // MARK: - Log & Freeze
    func logAsLearned() {
        let today = Calendar.current.startOfDay(for: Date())
        guard !isLearned, !isFreezed else { return }
        isLearned = true
        userGoal.learnedDates.insert(today)
        userGoal.lastLoggedDate = today
        saveProgress()
    }

    func freezeDay() {
        let today = Calendar.current.startOfDay(for: Date())
        guard !userGoal.freezedDates.contains(today) && usedFreezesForPeriod < userGoal.period.freezeLimit else { return }
        userGoal.freezedDates.insert(today)
        isFreezed = true
        saveProgress()
    }

    // MARK: - Week & month helpers
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

    // MARK: - Codable helpers
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
        userGoal.text = data.text
        userGoal.period = UserGoal.Period(rawValue: data.period) ?? .week
        userGoal.lastLoggedDate = data.lastLoggedDate
        userGoal.learnedDates = Set(data.learnedDates)
        userGoal.freezedDates = Set(data.freezedDates)
        isLearned = isLearnedToday
        isFreezed = isFreezedToday
    }

    // MARK: - Save & Load
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
