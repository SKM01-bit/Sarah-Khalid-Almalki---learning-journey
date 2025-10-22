//
//  Model.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//


import SwiftUI
import Combine
import Foundation

class UserGoal: ObservableObject {
    enum Period: String {
        case week
        case month
        case year

        var freezeLimit: Int {
            switch self {
            case .week: return 2
            case .month: return 8
            case .year: return 96
            }
        }
    }

    // Original properties
    var text: String
    var period: Period
    @Published var streak: Int
    @Published var lastLoggedDate: Date?
    @Published var usedFreezes: Int
    
    var freezeLimit: Int { period.freezeLimit }

    // NEW: track which dates were learned or freezed
    @Published var learnedDates: Set<Date> = []
    @Published var freezedDates: Set<Date> = []

    // Initializer
    init(text: String, period: Period, streak: Int, lastLoggedDate: Date?, usedFreezes: Int) {
        self.text = text
        self.period = period
        self.streak = streak
        self.lastLoggedDate = lastLoggedDate
        self.usedFreezes = usedFreezes
        self.learnedDates = []
        self.freezedDates = []
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
