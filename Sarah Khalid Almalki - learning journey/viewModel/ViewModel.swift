//
//  SwiftUIView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//

import SwiftUI

@MainActor
class LearningViewModel: ObservableObject {
    @Published var userGoal: UserGoal
    @Published var isButtonDisabled = false
    @Published var buttonColor: Color = .orange.opacity(0.5)

    init(userGoal: UserGoal) {
        self.userGoal = userGoal
        checkButtonState()
    }

    func logAsLearned() {
        guard !isButtonDisabled else { return }
        userGoal.lastLoggedDate = Date()
        userGoal.streak += 1
        buttonColor = Color(red: 0.70, green: 0.25, blue: 0.0)
        disableButtonUntilMidnight()
    }

    func freezeDay() {
        guard userGoal.usedFreezes < userGoal.freezeLimit else { return }
        userGoal.usedFreezes += 1
        disableButtonUntilMidnight()
    }

    func disableButtonUntilMidnight() {
        isButtonDisabled = true
        // Enable again at midnight
        let nextMidnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0), matchingPolicy: .nextTime)!
        let timeInterval = nextMidnight.timeIntervalSinceNow
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            self.isButtonDisabled = false
            self.buttonColor = .orange.opacity(0.5)
        }
    }

    func checkButtonState() {
        if userGoal.usedFreezes >= userGoal.freezeLimit {
            isButtonDisabled = true
        }
    }
}
