//
//  CompletionView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 04/05/1447 AH.
//
import SwiftUI

struct CompletionView: View {
    var userGoal: UserGoal
    var onSetNewGoal: () -> Void
    var onSetSameGoal: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hands.and.sparkles.fill")
                .foregroundColor(.orange)
                .font(.system(size: 40))
            
            Text("Well Done!")
                .font(.title2.bold())
            
            Text("Goal completed! Start learning again or set a new learning goal.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Set New Goal Button
            Button(action: {
                onSetNewGoal()  // closure passed from WeeklyCalendarView
            }) {
                Text("Set new learning goal")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.70, green: 0.25, blue: 0.0))
                    .cornerRadius(30)
            }
            
            // Set Same Goal & Duration Button
            Button(action: {
                onSetSameGoal()  // closure passed from WeeklyCalendarView
            }) {
                Text("Set same learning goal and duration")
                    .foregroundColor(.orange)
            }
        }

        .padding()
    }
}

#Preview {
    let sampleGoal = UserGoal(
        text: "Swift",
        period: .week,
        streak: 7,
        lastLoggedDate: nil,
        usedFreezes: 0
    )
    
    CompletionView(
        userGoal: sampleGoal,
        onSetNewGoal: { print("New Goal tapped") },
        onSetSameGoal: { print("Same Goal tapped") }
    )
    .preferredColorScheme(.dark)
}

