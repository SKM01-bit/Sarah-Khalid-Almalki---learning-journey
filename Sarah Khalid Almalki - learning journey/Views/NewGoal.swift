//
//  NewGoal.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 01/05/1447 AH.
//
import SwiftUI

struct NewGoal: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var userGoal: UserGoal
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText: String
    @State private var selectedPeriod: UserGoal.Period
    @State private var showConfirmAlert = false

    init(userGoal: UserGoal, viewModel: ViewModel) {
        self.userGoal = userGoal
        self.viewModel = viewModel
        _inputText = State(initialValue: userGoal.text)
        _selectedPeriod = State(initialValue: userGoal.period)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }

                    Spacer()
                    Text("Learning Goal")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                        showConfirmAlert = true
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                Spacer()
                Spacer()

                // MARK: - Form Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("\nI want to learn")
                        .font(.system(size: 20))
                        .fontWeight(.medium)

                    TextField("Enter your goal...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: inputText) { newValue in
                            userGoal.text = newValue
                            userGoal.save()
                        }

                    Text("\n\nI want to learn it in a")
                        .font(.system(size: 20))
                        .fontWeight(.medium)

                    HStack(spacing: 12) {
                        ForEach(UserGoal.Period.allCases, id: \.self) { period in
                            Button {
                                selectedPeriod = period
                                userGoal.period = period
                                userGoal.save()
                            } label: {
                                Text(period.rawValue.capitalized)
                                    .frame(width: 100, height: 48)
                                    .foregroundColor(.white)
                                    .background(
                                        selectedPeriod == period
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
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .alert("Are you sure you want to update your goal? Your streak will reset.", isPresented: $showConfirmAlert) {
            Button("Update") {
                userGoal.text = inputText
                userGoal.period = selectedPeriod
                userGoal.save()
                viewModel.resetForSameGoal()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Dismiss", role: .cancel) { }
        }
    }
}

#Preview {
    let sampleGoal = UserGoal(
        text: "",
        period: .month,
        streak: 5,
        lastLoggedDate: nil,
        usedFreezes: 0
    )
    let sampleViewModel = ViewModel(userGoal: sampleGoal)
    NewGoal(userGoal: sampleGoal, viewModel: sampleViewModel)
        .preferredColorScheme(.dark)
}
