//
//  Model.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//



import Foundation

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


struct UserGoal {
    var text: String
    var period: Period
    var streak: Int
    var lastLoggedDate: Date?
    var usedFreezes: Int
    
    var freezeLimit: Int {
        period.freezeLimit
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
