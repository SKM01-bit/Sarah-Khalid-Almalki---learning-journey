//
//  WeeklyCalendarView.swift
//  Sarah Khalid Almalki - learning journey
//
//  Created by Sarah Khalid Almalki on 29/04/1447 AH.
//


import SwiftUI

struct WeeklyCalendarView: View {
    // MARK: - Core Objects
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    
    // MARK: - Local State
    @State private var showCompletion = false
    
    // MARK: - Constants
    let calendar = Calendar.current
    let months = DateFormatter().monthSymbols ?? []
    let years = Array(2000...2100)
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerView
                calendarCard
                if showCompletion || viewModel.currentStreak >= viewModel.streakTarget {
                    completionView
                        .transition(.opacity)
                } else {
                    logAndFreezeButtons
                }
            }
            .onChange(of: viewModel.userGoal.streak) { newValue in
                if newValue >= viewModel.streakTarget {
                    showCompletion = true
                }
            }
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack(spacing: 20) {
            Text("Activity")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(10)
            Spacer()
            NavigationLink(destination: CalendarProgressView(viewModel: viewModel)) {
                Image(systemName: "calendar")
                    .font(.system(size: 27))
                    .foregroundColor(.white)
            }
            NavigationLink(destination: NewGoal(userGoal: viewModel.userGoal, viewModel: viewModel)) {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 27))
                    .foregroundColor(.white)
            }
        }
        .padding(10)
    }
    
    // MARK: - Calendar Card
    var calendarCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .frame(width: 390, height: 230)
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
                calendarHeader
                weekRow
                Divider()
                    .background(Color.white.opacity(0.4))
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                streakAndFreezes
            }
            .zIndex(1)
        }
    }
    
    var calendarHeader: some View {
        HStack {
            Text("\(viewModel.monthTitle)")
                .font(.title2.bold())
            Button(action: { viewModel.showMonthPicker = true }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
            }
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
        .padding(.top, 5)
    }
    
    var weekRow: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.weekDates, id: \.self) { date in
                VStack {
                    Text(viewModel.dayOfWeek(from: date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(viewModel.dayOfMonth(from: date))
                        .frame(width: 34, height: 34)
                        .background(circleColor(for: date))
                        .foregroundColor(textColor(for: date))
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    var streakAndFreezes: some View {
        HStack(spacing: 30) {
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
            
            ZStack {
                Rectangle()
                    .frame(width: 160, height: 69)
                    .cornerRadius(34)
                    .foregroundColor(Color(red: 0.1, green: 0.64, blue: 0.8).opacity(0.4))
                Image(systemName: "cube.fill")
                    .offset(x: -50)
                    .foregroundColor(Color(red: 0.1, green: 0.64, blue: 0.8))
                    .font(.system(size: 20, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.userGoal.freezedDates.count)")
                        .font(.system(size: 20))
                        .offset(x: 10, y: -5)
                    Text(viewModel.userGoal.freezedDates.count == 1 ? "Day Freezed" : "Days Freezed")
                        .offset(x: 10, y: 10)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }
    
    // MARK: - Log & Freeze Buttons
    var logAndFreezeButtons: some View {
        VStack(spacing: 10) {
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
            
            Button {
                viewModel.freezeDay()
            } label: {
                Text(viewModel.isFreezedToday ? "Freezed" : "Log as Freezed")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(viewModel.isFreezedToday ? Color.blue.opacity(0.3) : Color(red: 0.1, green: 0.64, blue: 0.8).opacity(0.9))
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .disabled(
                viewModel.userGoal.freezedDates.count >= viewModel.userGoal.period.freezeLimit
                || viewModel.isFreezedToday
                || viewModel.isLearnedToday
            )
            
            Text("\(viewModel.userGoal.freezedDates.count) out of \(viewModel.userGoal.period.freezeLimit) Freezes Used")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.bottom)
    }
    
    // MARK: - Completion View
    var completionView: some View {
        CompletionView(
            viewModel: viewModel,
            onSetNewGoal: {
                // Ensure no old saved data overrides the next new goal
                viewModel.clearSavedProgress()
                dismiss()
            },
            onSetSameGoal: {
                viewModel.resetForSameGoal()
                showCompletion = false
            }
        )
    }
    
    // MARK: - Helpers
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
    
    // MARK: - Nested Completion View
    struct CompletionView: View {
        @ObservedObject var viewModel: ViewModel
        var onSetNewGoal: () -> Void
        var onSetSameGoal: () -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "hands.and.sparkles.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 50))
                    .padding(.bottom, 10)
                
                Text("Well Done!")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                
                Text("You successfully completed your goal to learn **\(viewModel.userGoal.text)** for a **\(viewModel.userGoal.period.rawValue.capitalized)**.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer().frame(height: 30)
                
                Button(action: onSetNewGoal) {
                    Text("Set a New Goal")
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color(red: 0.70, green: 0.25, blue: 0.0))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 3)
                }
                
                Button(action: onSetSameGoal) {
                    Text("Start the same goal again")
                        .foregroundColor(.orange)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleGoal = UserGoal(
        text: "Swift",
        period: .month,
        streak: 0,
        lastLoggedDate: nil,
        usedFreezes: 0
    )
    
    let sampleVM = ViewModel(userGoal: sampleGoal)
    
    return WeeklyCalendarView(viewModel: sampleVM)
        .preferredColorScheme(.dark)
}

/*// 👇 Popup for Month & Year selection .sheet(isPresented: $showMonthPicker) { VStack(spacing: 20) { Text("Select Month & Year") .font(.headline) .padding(.top) // Month Picker HStack { Picker("Month", selection: $selectedMonth) { ForEach(1...12, id: \.self) { index in Text(months[index - 1]).tag(index) } } .pickerStyle(WheelPickerStyle()) .frame(maxWidth: .infinity) Picker("Year", selection: $selectedYear) { ForEach(years, id: \.self) { year in Text("\(year)").tag(year) } } .pickerStyle(WheelPickerStyle()) .frame(maxWidth: .infinity) } .frame(height: 200) // optional to control picker height .pickerStyle(WheelPickerStyle()) Button("Done") { showMonthPicker = false // Later: trigger calendar update based on selectedMonth & selectedYear } .padding() .background(Color.orange.opacity(0.2)) .cornerRadius(10) } .presentationDetents([.medium]) .padding() }*/
