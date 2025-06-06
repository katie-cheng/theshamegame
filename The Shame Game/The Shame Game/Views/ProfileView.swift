import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var authService: AuthService
    @State private var showingEditProfile = false
    @State private var weeklyScores: [DailyScore] = []
    @State private var weeklyWakeUps: [WakeUpLog] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    if let user = authService.user {
                        // Profile Header
                        profileHeader(user: user)
                        
                        // Today's Stats
                        todaysStatsCard
                        
                        // Weekly Charts
                        weeklyChartsSection
                        
                        // Achievement Section
                        achievementsSection(user: user)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(Theme.Colors.primaryBlue)
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                    .foregroundColor(Theme.Colors.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            if let user = authService.user {
                EditProfileView(user: user)
            }
        }
        .onAppear {
            loadData()
        }
        .refreshable {
            loadData()
        }
    }
    
    @ViewBuilder
    private func profileHeader(user: User) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            // Profile picture
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .overlay(
                        Text(user.displayName.prefix(1).uppercased())
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.primaryText)
                    )
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // User info
            VStack(spacing: Theme.Spacing.xs) {
                Text(user.displayName)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.primaryText)
                    .fontWeight(.bold)
                
                Text("Sleep Goal: \(user.sleepGoal)")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.primaryBlue)
            }
            
            // Stats row
            HStack(spacing: Theme.Spacing.xl) {
                statItem(title: "Current Streak", value: "\(user.currentStreak)")
                statItem(title: "Longest Streak", value: "\(user.longestStreak)")
                statItem(title: "Total Score", value: "\(user.totalScore)")
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.primaryText)
                .fontWeight(.bold)
            
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    @ViewBuilder
    private var todaysStatsCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Today's Performance")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Spacer()
                
                if let score = gameService.todaysScore {
                    Text("\(score.score)/100")
                        .font(Theme.Typography.title3)
                        .foregroundColor(scoreColor(score.score))
                        .fontWeight(.bold)
                } else {
                    Text("No data")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            if let wakeUp = gameService.todaysWakeUp {
                HStack {
                    Text("Woke up at:")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                                            Text(DateFormatter.timeOnly.string(from: wakeUp.timestamp))
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primaryText)
                        .fontWeight(.medium)
                }
            } else {
                HStack {
                    Text("Status:")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text(gameService.canWakeUp ? "Ready to wake up!" : "Not time yet")
                        .font(Theme.Typography.callout)
                        .foregroundColor(gameService.canWakeUp ? Theme.Colors.success : Theme.Colors.warning)
                        .fontWeight(.medium)
                }
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var weeklyChartsSection: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Sleep Scores Chart
            if !weeklyScores.isEmpty {
                sleepScoresChart
            }
            
            // Wake Up Times Chart
            if !weeklyWakeUps.isEmpty {
                wakeUpTimesChart
            }
        }
    }
    
    @ViewBuilder
    private var sleepScoresChart: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Weekly Sleep Scores")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Spacer()
            }
            
            Chart {
                ForEach(weeklyScores, id: \.date) { score in
                    BarMark(
                        x: .value("Date", shortDateString(score.date)),
                        y: .value("Score", score.score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.primaryBlue, Theme.Colors.primaryPurple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var wakeUpTimesChart: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Weekly Wake-up Times")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Spacer()
            }
            
            Chart {
                ForEach(weeklyWakeUps, id: \.id) { wakeUp in
                    LineMark(
                        x: .value("Date", shortDateString(wakeUp.timestamp)),
                        y: .value("Time", wakeUpTimeInMinutes(wakeUp.timestamp))
                    )
                    .foregroundStyle(Theme.Colors.success)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", shortDateString(wakeUp.timestamp)),
                        y: .value("Time", wakeUpTimeInMinutes(wakeUp.timestamp))
                    )
                    .foregroundStyle(Theme.Colors.success)
                    .symbolSize(50)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 360...720) // 6 AM to 12 PM in minutes
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            Text(timeStringFromMinutes(minutes))
                        }
                    }
                    .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func achievementsSection(user: User) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Achievements")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.md) {
                achievementCard(
                    emoji: "🌅",
                    title: "Early Bird",
                    description: "Wake up on time 7 days in a row",
                    isUnlocked: user.currentStreak >= 7
                )
                
                achievementCard(
                    emoji: "🔥",
                    title: "Streak Master",
                    description: "15 day wake-up streak",
                    isUnlocked: user.longestStreak >= 15
                )
                
                achievementCard(
                    emoji: "😈",
                    title: "Shamer",
                    description: "Shame 10 friends",
                    isUnlocked: user.totalScore >= 500
                )
                
                achievementCard(
                    emoji: "🎯",
                    title: "Consistent",
                    description: "Score 80+ for a week",
                    isUnlocked: weeklyScores.allSatisfy { $0.score >= 80 }
                )
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func achievementCard(emoji: String, title: String, description: String, isUnlocked: Bool) -> some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(emoji)
                .font(.system(size: 30))
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            Text(title)
                .font(Theme.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? Theme.Colors.primaryText : Theme.Colors.secondaryText)
            
            Text(description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.sm)
        .background(isUnlocked ? Theme.Colors.success.opacity(0.1) : Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    // Helper methods
    private func loadData() {
        guard let userId = authService.currentUser?.uid else { return }
        
        Task {
            await gameService.loadTodaysData()
            weeklyScores = await gameService.getWeeklyScores(userId: userId)
            weeklyWakeUps = await gameService.getWeeklyWakeUps(userId: userId)
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 {
            return Theme.Colors.success
        } else if score >= 60 {
            return Theme.Colors.warning
        } else {
            return Theme.Colors.danger
        }
    }
    
    private func shortDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    private func wakeUpTimeInMinutes(_ date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour * 60 + minute
    }
    
    private func timeStringFromMinutes(_ minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%d:%02d", hour, minute)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var user: User
    @State private var selectedTimeComponents = DateComponents()
    @State private var isLoading = false
    
    init(user: User) {
        self._user = State(initialValue: user)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("Display Name", text: $user.displayName)
                }
                
                Section("Sleep Goal") {
                    DatePicker(
                        "Wake-up time",
                        selection: Binding(
                            get: { sleepGoalDate },
                            set: { newDate in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm"
                                user.sleepGoal = formatter.string(from: newDate)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private var sleepGoalDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: user.sleepGoal) ?? Date()
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            let success = await authService.updateProfile(
                displayName: user.displayName,
                sleepGoal: user.sleepGoal,
                bedtimeGoal: user.bedtimeGoal
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    // Handle error
                    print("Error updating profile")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameService())
        .environmentObject(AuthService())
} 