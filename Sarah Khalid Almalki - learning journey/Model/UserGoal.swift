//
//  Model.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//


import Foundation

struct UserGoal {
    var goalType: String // "Week", "Month", "Year"
    var startDate: Date
    var freezeLimit: Int
    var streak: Int
    var lastLoggedDate: Date?
    var usedFreezes: Int
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
