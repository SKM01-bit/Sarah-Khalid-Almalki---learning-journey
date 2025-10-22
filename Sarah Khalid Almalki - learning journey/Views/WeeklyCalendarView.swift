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
    
    let calendar = Calendar.current
    let months = DateFormatter().monthSymbols ?? []
    let years = Array(2000...2100)
    
    init(userGoal: UserGoal) {
            _viewModel = StateObject(wrappedValue: ViewModel(userGoal: userGoal))
        }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20){
                Text("Activity")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(10)
                Spacer()
                Button(action: {
                    print("Calendar tapped!")
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 27))
                        .foregroundColor(.white)
                }
                Button(action: {
                    print("Calendar tapped!")
                }){
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 27))
                        .foregroundColor(.white)
                }
            }
            .padding(10)
            // Calendar ZStack with background
            ZStack {
                // Background rounded rectangle
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
                    .frame(width: 390, height: 230)
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
                
                VStack(spacing: 10) {
                    // Month title + chevrons
                    HStack {
                        Text("\(viewModel.monthTitle)")
                            .font(.title2.bold())
                        
                        Button(action: { showMonthPicker = true }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        Spacer()
                        Button(action: { viewModel.currentWeekOffset -= 1 }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        Button(action: { viewModel.currentWeekOffset += 1 }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5) // shift up a bit
                    
                    // Weekday row
                    HStack(spacing: 12) {
                        ForEach(viewModel.weekDates, id: \.self) { date in
                            let isToday = viewModel.isToday(date)
                            let isLearned = viewModel.isLearned(date)
                            let isFreezed = viewModel.isFreezed(date)
                            
                            VStack {
                                Text(viewModel.dayOfWeek(from: date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(viewModel.dayOfMonth(from: date))
                                    .frame(width: 34, height: 34)
                                    .background(
                                        viewModel.isLearned(date) ? Color.orange.opacity(0.2) :
                                        viewModel.isFreezed(date) ? Color.blue.opacity(0.2) :
                                        viewModel.isToday(date) ? Color.orange : Color.clear
                                    )
                                    .foregroundColor(
                                        viewModel.isLearned(date) ? .orange :
                                        viewModel.isFreezed(date) ? .blue :
                                        viewModel.isToday(date) ? .white : .primary
                                    )

                                    .clipShape(Circle())
                                    .foregroundColor(
                                        isLearned ? .orange :
                                            isFreezed ? .blue :
                                            isToday ? .white : .primary
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    .padding(.horizontal)
                    
                    // Divider line
                    Divider()
                        .background(Color.white.opacity(0.4))
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    // Streak and Freeze cards
                    HStack(spacing: 30) {
                        // Streak
                        ZStack {
                            Rectangle()
                                .frame(width: 160, height: 69)
                                .cornerRadius(34)
                                .foregroundColor(.orange.opacity(0.4))
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 20, weight: .bold))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(viewModel.userGoal.streak)")
                                        .font(.system(size: 20))
                                    Text(viewModel.userGoal.streak == 1 ? "Day Learned" : "Days Learned")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        
                        // Freezes
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
                            Text(viewModel.userGoal.usedFreezes == 1 ? "Day Freezed" : "Days Freezed")
                                .offset(x: 10, y: 15)
                                .font(.system(size: 14))
                        }
                    }
                    
                    .padding(.horizontal)
                    .padding(.top, 6)
                }
                .zIndex(1) // ensures all these are above the background
            }
            
            
        }
        .sheet(isPresented: $showMonthPicker) {
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { index in
                        Text(months[index - 1]).tag(index)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(height: 150)
            .padding()
        }
        
        // Log as Learned button
        Button {
            viewModel.logAsLearned()
        } label: {
            Circle()
                .fill(viewModel.isLearnedToday ? Color.orange.opacity(0.2) : Color(red: 0.70, green: 0.25, blue: 0.0))
                .frame(width: 300, height: 300)
                .overlay(
                    Text(viewModel.isLearnedToday ? "Learned Today" : "Log as Learned")
                        .font(.system(size: 31, weight: .bold))
                        .foregroundColor(viewModel.isLearnedToday ? Color.orange.opacity(0.2) : Color.white)
                )
        }
        .disabled(viewModel.isLearnedToday || viewModel.isFreezedToday)


              
              .padding()
          
        
        VStack(spacing: 10) {
            Button {
                viewModel.freezeDay()
            } label: {
                Text(viewModel.isFreezedToday ? "Freezed" : "Log as Freezed")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        viewModel.isFreezedToday ? Color.blue.opacity(0.3) : Color(red: 0.1, green: 0.64, blue: 0.8).opacity(0.9)
                    )
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .disabled(viewModel.isLearnedToday || viewModel.isFreezedToday)


            Text("\(viewModel.userGoal.usedFreezes) out of \(viewModel.userGoal.period.freezeLimit) Freezes Used")
                .foregroundColor(.gray)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .font(.subheadline)
        }

        .padding(.bottom)
        
    }

    func circleColor(for date: Date) -> Color {
            if viewModel.isLearned(date) { return Color.orange.opacity(0.2) }
            if viewModel.isFreezed(date) { return Color.blue.opacity(0.2) }
            if viewModel.isToday(date) { return Color.orange }
            return Color.clear
        }

        func textColor(for date: Date) -> Color {
            if viewModel.isLearned(date) { return Color.orange }
            if viewModel.isFreezed(date) { return Color.blue }
            if viewModel.isToday(date) { return Color.white }
            return Color.primary
        }
    }
    

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
