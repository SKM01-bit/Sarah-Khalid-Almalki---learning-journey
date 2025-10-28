//
//  ContentView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 24/04/1447 AH.
//
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var scheme

    @State private var inputText: String = ""
    @State private var navigate = false
    @ObservedObject var userGoal: UserGoal
    @State private var selectedPeriod: UserGoal.Period

    // ✅ Public init so #Preview works
    init(userGoal: UserGoal = UserGoal.load()) {
        UserDefaults.standard.removeObject(forKey: "savedUserGoal") // optional: reset everything
        self.userGoal = userGoal
        _selectedPeriod = State(initialValue: userGoal.period)
        _inputText = State(initialValue: userGoal.text)
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 40) {
                    // 🔥 Top flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding(35)
                        .background(
                            Circle()
                                .fill(Color(red: 0.36, green: 0.20, blue: 0.06)
                                    .opacity(scheme == .dark ? 0.2 : 0.9))
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.4),
                                            Color.orange.opacity(0.6),
                                            Color.orange.opacity(0.2),
                                            Color.yellow.opacity(0.9),
                                            Color.orange.opacity(0.2),
                                            Color.orange.opacity(0.4)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 1
                                )
                        )

                    // 👋 Greeting & Input
                    VStack(alignment: .leading) {
                        Text("Hello Learner")
                            .font(.system(size: 35, weight: .bold))
                        Text("This app will help you learn everyday!\n\n")
                            .foregroundColor(.gray)

                        Text("I want to learn")
                            .font(.system(size: 20))
                        TextField("Swift", text: $inputText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: inputText) { newValue in
                                userGoal.text = newValue
                                userGoal.save()
                            }

                        Text("\nI want to learn it in a")
                            .font(.system(size: 20))

                        // 🗓 Period selection buttons
                        HStack(spacing: 15) {
                            ForEach(UserGoal.Period.allCases, id: \.self) { periodEnum in
                                Button(action: {
                                    selectedPeriod = periodEnum
                                    userGoal.period = periodEnum
                                    userGoal.save()
                                }) {
                                    Text(periodEnum.rawValue.capitalized)
                                        .frame(width: 97, height: 48)
                                        .glassEffect(.clear)
                                        .foregroundColor(Color("Color"))
                                        .background(
                                            selectedPeriod == periodEnum
                                            ? Color(red: 0.70, green: 0.25, blue: 0.0)
                                            : Color.black.opacity(0.4)
                                        )
                                        .cornerRadius(40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.white.opacity(0.4),
                                                            Color.black.opacity(0.3),
                                                            Color.white.opacity(0.4)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
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

                // 🔘 Start Learning Button
                VStack {
                    Button(action: {
                        userGoal.text = inputText
                        userGoal.period = selectedPeriod
                        userGoal.save()
                        navigate = true
                    }) {
                        Text("Start learning")
                            .frame(width: 182, height: 48)
                            .background(Color(red: 0.70, green: 0.25, blue: 0.0))
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 3)
                            .foregroundColor(.white)
                    }

                    NavigationLink(
                        destination: WeeklyCalendarView(
                            viewModel: ViewModel(userGoal: userGoal)
                        ),
                        isActive: $navigate
                    ) {
                        EmptyView()
                    }
                }
            }
            // ✅ Keeps UI synced with stored goal each time it reappears
            .onAppear {
                inputText = userGoal.text
                selectedPeriod = userGoal.period
            }
        }
    }
}

#Preview {
    let previewGoal = UserGoal(
        text: "Swift",
        period: .month,
        streak: 0,
        lastLoggedDate: nil,
        usedFreezes: 0
    )
    ContentView(userGoal: previewGoal)
        .preferredColorScheme(.dark)
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
