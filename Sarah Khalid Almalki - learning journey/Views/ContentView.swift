//
//  ContentView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 24/04/1447 AH.
//

import SwiftUI

struct ContentView: View {
    @State private var learnGoal: String = ""
    @State private var selectedPeriod = "Week"

    var body: some View {
        VStack {
            VStack(spacing: 40) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .padding(35)
                    .background(
                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.orange.opacity(0.4),
                                        Color.orange.opacity(0.25),
                                        Color.orange.opacity(0.8),
                                        Color.orange.opacity(0.3),
                                        Color.orange.opacity(0.8),
                                        Color.orange.opacity(0.4)
                                    ]),
                                    center: .center
                                )
                            )
                    )

                VStack(alignment: .leading) {
                    Text("Hello Learner")
                        .font(.system(size: 35, weight: .bold))
                    Text("This app will help you learn everyday!\n\n")
                        .foregroundColor(.gray)
                    Text("I want to learn")
                        .font(.system(size: 20))
                    TextField("Ex: Swift", text: $learnGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("\nI want to learn it in a")
                        .font(.system(size: 20))

                    HStack(spacing: 15) {
                        ForEach(["Week", "Month", "Year"], id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                            }) {
                                Text(period)
                                    .frame(width: 80, height: 40)
                                    .glassEffect(.clear)
                                    .foregroundColor(.white)
                                    .background(selectedPeriod == period ? Color(red: 1.0, green: 0.4, blue: 0.0) : Color.clear)
                                    .cornerRadius(40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 40)
                                            .stroke(Color.clear, lineWidth: 1)
                                            .buttonStyle(.glass)
                                    )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

            Spacer()

            // Bottom Centered Start Learning Button
            Button(action: {
                print("Start learning tapped with goal: \(learnGoal) for \(selectedPeriod)")
            }) {
                Text("Start learning")
                    .frame(maxWidth: 200, maxHeight: 50)
                    .background(Color(red: 1.0, green: 0.4, blue: 0.0))
                    .foregroundColor(.white)
                    .cornerRadius(40)
            }
            .padding(.bottom, 40) // safe area padding at bottom
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}




/*width: 109px;
height: 109px;
box-shadow: 2px 2px 0.25px -2px inset rgba(255, 255, 255, 1);
border-radius: 1000px;
opacity: 0.45;*/
// Glassy gradient ring
/*    Circle()
 .stroke(
 AngularGradient(
 gradient: Gradient(colors: [
 Color.orange.opacity(0.6),
 Color(red: 1.0, green: 0.7, blue: 0.3, opacity: 0.5),
 Color.orange.opacity(0.6)
 ]),
 center: .center
 ),
 lineWidth: 12
 )
 .frame(width: 180, height: 180)
 .background(
 Circle()
 .fill(.ultraThinMaterial) // Apple's glass blur material
 .blur(radius: 10)
 .opacity(0.2)
 )
 .overlay(
 // Inner white highlight
 Circle()
 .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
 .blur(radius: 1)
 )
 .shadow(color: Color.orange.opacity(0.3), radius: 12, x: 0, y: 6)
 .blendMode(.plusLighter)
 }*/
