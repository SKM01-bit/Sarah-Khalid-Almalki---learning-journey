//
//  WellDone.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 04/05/1447 AH.
//

import SwiftUI

struct WellDone: View {
    var body: some View {
        VStack{
            Image(systemName: "hands.and.sparkles.fill")
                .foregroundColor(Color(.orange))
                .font(.system(size: 40))
                .padding(3)
            Text("Well Done!")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text("Goal completed! start learning again or set new learning goal\n\n")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button(action: {
                print("well done heyyhyh") // <-- put your action code here
            }) {
                Text("Set new learning goal")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.70, green: 0.25, blue: 0.0))
                    .cornerRadius(30)
            }
            Button(action: {
                print("well done heyyhyh") // <-- put your action code here
            }) {
                Text("Set same learning goal and duration")
                    .foregroundColor(.orange)
                    
            }

        }
    }
}

#Preview {
    WellDone()
}
