//
//  WeeklyCalendarView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @State private var currentWeekOffset = 0
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showMonthPicker = false
    @State private var isLearned = false
    @State private var isFreezed = false
    @StateObject var viewModel: ViewModel
    
    init(userGoal: UserGoal) {
        _viewModel = StateObject(wrappedValue: ViewModel(userGoal: userGoal))
    }




    
    let calendar = Calendar.current
    let months = DateFormatter().monthSymbols ?? []
    let years = Array(2000...2100)

    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .frame(width: 390, height: 254)
                .mask(RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            VStack(spacing: 20) {
                
                // Month title and chevron
                HStack {
                    Text("October 2025") // Static placeholder
                        .font(.title2.bold())
                    Button(action: { showMonthPicker = true }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { currentWeekOffset -= 1 }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        Button(action: { currentWeekOffset += 1 }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Week days row (static)
                HStack(spacing: 12) {
                    ForEach(viewModel.weekDates, id: \.self) { date in
                        VStack {
                            Text(viewModel.dayOfWeek(from: date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.dayOfMonth(from: date))
                                .font(.headline)
                                .foregroundColor(viewModel.isToday(date) ? .orange : .primary)
                                .frame(width: 34, height: 34)
                                .background(viewModel.isToday(date) ? Color.orange.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                        }
                        .frame(maxWidth: .infinity)
                    }

                        }

                .padding(.horizontal)
                
                
                
                HStack(spacing: 30) {
                    ZStack {
                        Rectangle()
                            .frame(width: 160, height: 69)
                            .cornerRadius(34)
                            .foregroundColor(.orange.opacity(0.4))
                        Image(systemName: "flame.fill")
                            .offset(x: -50)
                            .foregroundColor(.orange)
                            .font(.system(size: 20, weight: .bold))
                        Text("\(viewModel.userGoal.streak)")
                            .offset(y: -10)
                            .font(.system(size: 20))
                        
                        if viewModel.userGoal.streak == 1 {
                            Text("Day Learned")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                        else if viewModel.userGoal.streak > 1{
                            Text("Days Learned")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                        else{
                            Text("Day Learned")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }}
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 160, height: 69)
                            .cornerRadius(34)
                            .foregroundColor(Color(red: 0.1, green: 0.64, blue: 0.8).opacity(0.4))
                        Image(systemName: "cube.fill")
                            .offset(x: -50)
                            .foregroundColor(Color(red: 0.1, green: 0.64, blue: 0.8))
                            .font(.system(size: 20, weight: .bold))
                        Text("\(viewModel.userGoal.usedFreezes)")
                            .offset(y: -10)
                            .font(.system(size: 20))
                        if viewModel.userGoal.usedFreezes == 1 {
                            Text("Day Freezed")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                        else if viewModel.userGoal.usedFreezes > 1
                        {
                            Text("Days Freezed")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                        else{
                            Text("Day Freezed")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                            
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showMonthPicker) {
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { index in
                        Text(months[index-1]).tag(index)
                    }
                }
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
            }
            .padding()
        }
        
        VStack {
                // Log as Learned Button
                Button(action: {
                    // Only log if not already logged today
                    if !isLearned {
                        isLearned = true
                        viewModel.userGoal.streak += 1
                        viewModel.userGoal.lastLoggedDate = Date() // record today as logged
                    }
                }) {
                    Circle()
                        .fill(isLearned ? Color.orange.opacity(0.2) : Color(red: 0.70, green: 0.25, blue: 0.0))
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text(isLearned ? "Learned Today" : "Log as Learned")
                                .font(.system(size: 31, weight: .bold))
                                .foregroundColor(isLearned ? Color.orange.opacity(0.2) : Color.white)
                                .multilineTextAlignment(.center)
                                .frame(width: 120)
                        )
                }
                .padding()
            VStack(spacing: 10) {
                Button {
                    if !isFreezed && viewModel.userGoal.usedFreezes < viewModel.userGoal.freezeLimit {
                        isFreezed = true
                        viewModel.userGoal.usedFreezes += 1
                    }
                } label: {
                    Text(isFreezed ? "Freezed" : "Log as freezed")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, minHeight: 50) // expands horizontally
                        .background(isFreezed ? Color.blue.opacity(0.3) : Color(red: 0.1, green: 0.64, blue: 0.8).opacity(0.9))
                        .cornerRadius(28)
                        .padding(.horizontal)
                }

                // Show how many freezes used
                Text("\(viewModel.userGoal.usedFreezes) out of \(viewModel.userGoal.freezeLimit) Freezes Used")
                    .foregroundColor(Color.gray)
                    .font(.subheadline)
            }

            }
            .padding()
        }    }


#Preview {
    WeeklyCalendarView(
        userGoal: UserGoal(
            text: "Swift",
            period: .month,
            streak: 0,
            lastLoggedDate: nil,
            usedFreezes: 0
        )
    )
    .preferredColorScheme(.dark)
}




/*// 👇 Popup for Month & Year selection .sheet(isPresented: $showMonthPicker) { VStack(spacing: 20) { Text("Select Month & Year") .font(.headline) .padding(.top) // Month Picker HStack { Picker("Month", selection: $selectedMonth) { ForEach(1...12, id: \.self) { index in Text(months[index - 1]).tag(index) } } .pickerStyle(WheelPickerStyle()) .frame(maxWidth: .infinity) Picker("Year", selection: $selectedYear) { ForEach(years, id: \.self) { year in Text("\(year)").tag(year) } } .pickerStyle(WheelPickerStyle()) .frame(maxWidth: .infinity) } .frame(height: 200) // optional to control picker height .pickerStyle(WheelPickerStyle()) Button("Done") { showMonthPicker = false // Later: trigger calendar update based on selectedMonth & selectedYear } .padding() .background(Color.orange.opacity(0.2)) .cornerRadius(10) } .presentationDetents([.medium]) .padding() }*/
