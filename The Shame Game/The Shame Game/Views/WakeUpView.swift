import SwiftUI

struct WakeUpView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var authService: AuthService
    @State private var mathAnswer = ""
    @State private var showingMathChallenge = false
    @State private var isAnswerIncorrect = false
    @State private var shakeOffset = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(spacing: Theme.Spacing.md) {
                        Text("☀️")
                            .font(.system(size: 60))
                        
                        Text("Rise and Shine!")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.primaryText)
                        
                        if let user = authService.user {
                            Text("Goal: \(user.sleepGoal)")
                                .font(Theme.Typography.callout)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                    }
                    .padding(.top, Theme.Spacing.lg)
                    .frame(maxWidth: .infinity)
                    
                    // Today's Status
                    if let wakeUp = gameService.todaysWakeUp {
                        todaysWakeUpCard(wakeUp: wakeUp)
                    } else {
                        wakeUpButtonSection
                    }
                    
                    // Today's Score
                    if let score = gameService.todaysScore {
                        todaysScoreCard(score: score)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $showingMathChallenge) {
            mathChallengeModal
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                await gameService.updateWakeUpAvailability()
            }
        }
        .refreshable {
            Task {
                await gameService.loadTodaysData()
                await gameService.updateWakeUpAvailability()
            }
        }
    }
    
    @ViewBuilder
    private var wakeUpButtonSection: some View {
        VStack(spacing: Theme.Spacing.lg) {
            if gameService.canWakeUp {
                Button("I WOKE UP! 🌅") {
                    gameService.initiateWakeUp()
                    showingMathChallenge = true
                    mathAnswer = ""
                    isAnswerIncorrect = false
                }
                .wakeUpButton()
                .disabled(gameService.isLoading)
                
            } else {
                VStack(spacing: Theme.Spacing.md) {
                    Text("⏰")
                        .font(.system(size: 50))
                    
                    Text("Not quite time yet...")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    if let user = authService.user {
                        Text("Come back at \(user.sleepGoal) or later!")
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                .cardStyle()
            }
        }
    }
    
    @ViewBuilder
    private func todaysWakeUpCard(wakeUp: WakeUpLog) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("✅")
                .font(.system(size: 50))
            
            Text("You're already up!")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.primaryText)
            
            VStack(spacing: Theme.Spacing.xs) {
                Text("Woke up at:")
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                                    Text(DateFormatter.timeOnly.string(from: wakeUp.timestamp))
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.success)
                    .fontWeight(.semibold)
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func todaysScoreCard(score: DailyScore) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Today's Score")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Spacer()
                
                Text("\(score.score)/100")
                    .font(Theme.Typography.title2)
                    .foregroundColor(scoreColor(score.score))
                    .fontWeight(.bold)
            }
            
            VStack(spacing: Theme.Spacing.sm) {
                scoreRow(label: "Wake-up timing", points: score.wakeUpPoints, maxPoints: 40)
                scoreRow(label: "Consistency", points: score.consistencyPoints, maxPoints: 30)
                scoreRow(label: "Sleep duration", points: score.sleepDurationPoints, maxPoints: 10)
                
                if score.shameDeductions > 0 {
                    scoreRow(label: "Shame penalty", points: -score.shameDeductions, maxPoints: 0, isNegative: true)
                }
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private func scoreRow(label: String, points: Int, maxPoints: Int, isNegative: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Spacer()
            
            Text(isNegative ? "\(points)" : "\(points)/\(maxPoints)")
                .font(Theme.Typography.callout)
                .foregroundColor(isNegative ? Theme.Colors.danger : Theme.Colors.primaryText)
                .fontWeight(.medium)
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
    
    @ViewBuilder
    private var mathChallengeModal: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: Theme.Spacing.md) {
                    Text("🧠")
                        .font(.system(size: 60))
                    
                    Text("Math Challenge")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text("Solve this to prove you're awake!")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                if let problem = gameService.mathProblem {
                    VStack(spacing: Theme.Spacing.lg) {
                        Text(problem.questionText)
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.primaryText)
                            .fontWeight(.bold)
                            .offset(x: shakeOffset)
                        
                        TextField("Your answer", text: $mathAnswer)
                            .themedTextField()
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(Theme.Typography.title3)
                            .onSubmit {
                                submitAnswer()
                            }
                        
                        if isAnswerIncorrect {
                            Text("Incorrect! Try again.")
                                .font(Theme.Typography.callout)
                                .foregroundColor(Theme.Colors.danger)
                                .transition(.opacity)
                        }
                        
                        Button("Submit") {
                            submitAnswer()
                        }
                        .primaryButton(isEnabled: !mathAnswer.isEmpty && !gameService.isLoading)
                        .disabled(gameService.isLoading)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
    
    private func submitAnswer() {
        guard let answer = Int(mathAnswer) else { return }
        
        Task {
            let isCorrect = await gameService.submitMathAnswer(answer)
            
            if isCorrect {
                showingMathChallenge = false
                await gameService.loadTodaysData()
            } else {
                withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                    shakeOffset = 10
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shakeOffset = 0
                }
                
                withAnimation {
                    isAnswerIncorrect = true
                    mathAnswer = ""
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isAnswerIncorrect = false
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    WakeUpView()
        .environmentObject(GameService())
        .environmentObject(AuthService())
} 
