//
//  Model.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//


import SwiftUI
import Combine
import Foundation

class UserGoal: ObservableObject, Codable {
    enum Period: String, Codable, CaseIterable {
        case week
        case month
        case year

    }

    // MARK: - Properties
    @Published var text: String
    @Published var period: Period
    @Published var streak: Int
    @Published var lastLoggedDate: Date?
    @Published var usedFreezes: Int
    @Published var learnedDates: Set<Date>
    @Published var freezedDates: Set<Date>

    var freezeLimit: Int { period.freezeLimit }

    // MARK: - Designated initializer
    init(
        text: String = "",
        period: Period = .week,
        streak: Int = 0,
        lastLoggedDate: Date? = nil,
        usedFreezes: Int = 0,
        learnedDates: Set<Date> = [],
        freezedDates: Set<Date> = []
    ) {
        self.text = text
        self.period = period
        self.streak = streak
        self.lastLoggedDate = lastLoggedDate
        self.usedFreezes = usedFreezes
        self.learnedDates = learnedDates
        self.freezedDates = freezedDates
    }

    // MARK: - Codable (manual because of @Published)
    private enum CodingKeys: String, CodingKey {
        case text, period, streak, lastLoggedDate, usedFreezes, learnedDates, freezedDates
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.period = try container.decode(Period.self, forKey: .period)
        self.streak = try container.decode(Int.self, forKey: .streak)
        self.lastLoggedDate = try container.decodeIfPresent(Date.self, forKey: .lastLoggedDate)
        self.usedFreezes = try container.decode(Int.self, forKey: .usedFreezes)
        self.learnedDates = try container.decodeIfPresent(Set<Date>.self, forKey: .learnedDates) ?? []
        self.freezedDates = try container.decodeIfPresent(Set<Date>.self, forKey: .freezedDates) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(period, forKey: .period)
        try container.encode(streak, forKey: .streak)
        try container.encodeIfPresent(lastLoggedDate, forKey: .lastLoggedDate)
        try container.encode(usedFreezes, forKey: .usedFreezes)
        try container.encode(learnedDates, forKey: .learnedDates)
        try container.encode(freezedDates, forKey: .freezedDates)
    }

    // MARK: - Persistence
    private static let fileName = "userGoal.json"

    func save() {
        let url = Self.getDocumentsDirectory().appendingPathComponent(Self.fileName)
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url, options: [.atomic])
            print("✅ UserGoal saved successfully")
        } catch {
            print("❌ Failed to save UserGoal:", error)
        }
    }

    static func load() -> UserGoal {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let goal = try? JSONDecoder().decode(UserGoal.self, from: data) {
            print("✅ UserGoal loaded successfully")
            return goal
        }
        print("⚠️ No saved UserGoal found, creating new one")
        return UserGoal()
    }

    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}










//struct UserGoal: Identifiable, Codable {
//    let id = UUID()
//    var text: String
//    var period: String      // Week, Month, Year
//    var startDate: Date = Date()
//    var streak: Int = 0
//    var usedFreezes: Int = 0
//    
//    // Max freezes based on period
//    var freezeLimit: Int {
//        switch period {
//        case "Week": return 2
//        case "Month": return 8
//        case "Year": return 96
//        default: return 0
//        }
//    }
//}
