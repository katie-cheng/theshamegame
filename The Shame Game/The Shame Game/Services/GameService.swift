import Foundation
// Commented out for mock testing
// import FirebaseFirestore
import UserNotifications

@MainActor
class GameService: ObservableObject {
    @Published var todaysWakeUp: WakeUpLog?
    @Published var todaysScore: DailyScore?
    @Published var recentWakeUps: [WakeUpLog] = []
    @Published var mathProblem: MathProblem?
    @Published var canWakeUp = true
    @Published var canBeShamed = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mock data
    private var mockWakeUps: [WakeUpLog] = []
    private var mockScores: [DailyScore] = []
    
    // Commented out for mock testing
    // private let db = Firestore.firestore()
    private let notificationService = NotificationService()
    
    struct MathProblem {
        let operand1: Int
        let operand2: Int
        let operation: Operation
        let correctAnswer: Int
        
        enum Operation: CaseIterable {
            case addition, subtraction
            
            var symbol: String {
                switch self {
                case .addition: return "+"
                case .subtraction: return "−"
                }
            }
        }
        
        var questionText: String {
            "\(operand1) \(operation.symbol) \(operand2) = ?"
        }
        
        static func generate() -> MathProblem {
            let operation = Operation.allCases.randomElement()!
            let operand1 = Int.random(in: 25...95)
            let operand2 = Int.random(in: 25...95)
            
            let correctAnswer: Int
            switch operation {
            case .addition:
                correctAnswer = operand1 + operand2
            case .subtraction:
                // Ensure positive result and meaningful difficulty
                let larger = max(operand1, operand2)
                let smaller = min(operand1, operand2)
                correctAnswer = larger - smaller
                return MathProblem(operand1: larger, operand2: smaller, operation: operation, correctAnswer: correctAnswer)
            }
            
            return MathProblem(operand1: operand1, operand2: operand2, operation: operation, correctAnswer: correctAnswer)
        }
    }
    
    init() {
        generateMockData()
    }
    
    private func generateMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate some recent wake-ups
        for i in 1...7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let wakeUpTime = calendar.date(bySettingHour: Int.random(in: 6...9), minute: Int.random(in: 0...59), second: 0, of: date)!
            
            let wakeUp = WakeUpLog(
                id: "mock-wakeup-\(i)",
                userId: "mock-user-123",
                timestamp: wakeUpTime,
                goalTime: "7:00 AM",
                actualTimeString: DateFormatter.timeOnly.string(from: wakeUpTime),
                mathProblemCorrect: true,
                shameCount: i == 2 ? 1 : 0 // Add some shame for variety
            )
            mockWakeUps.append(wakeUp)
            
            // Generate corresponding score
            let score = DailyScore(
                id: "mock-score-\(i)",
                userId: "mock-user-123",
                date: date,
                score: Int.random(in: 60...95),
                wakeUpPoints: Int.random(in: 25...40),
                consistencyPoints: Int.random(in: 15...30),
                sleepDurationPoints: Int.random(in: 5...10),
                shameDeductions: i == 2 ? 5 : 0
            )
            mockScores.append(score)
        }
        
        recentWakeUps = Array(mockWakeUps.prefix(5))
    }
    
    func loadTodaysData() async {
        isLoading = true
        
        // Minimal delay for mock testing
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        let calendar = Calendar.current
        let today = Date()
        
        // Check if we already have today's wake-up
        todaysWakeUp = mockWakeUps.first { wakeUp in
            calendar.isDate(wakeUp.timestamp, inSameDayAs: today)
        }
        
        // Check for today's score
        todaysScore = mockScores.first { score in
            calendar.isDate(score.date, inSameDayAs: today)
        }
        
        isLoading = false
    }
    
    func updateWakeUpAvailability() async {
        // For mock testing, always allow wake up if we haven't already today
        canWakeUp = todaysWakeUp == nil
    }
    
    func initiateWakeUp() {
        // Generate a harder 2-digit math problem
        let num1 = Int.random(in: 25...95)
        let num2 = Int.random(in: 25...95)
        let isAddition = Bool.random()
        
        if isAddition {
            mathProblem = MathProblem(
                operand1: num1,
                operand2: num2,
                operation: .addition,
                correctAnswer: num1 + num2
            )
        } else {
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            mathProblem = MathProblem(
                operand1: larger,
                operand2: smaller,
                operation: .subtraction,
                correctAnswer: larger - smaller
            )
        }
    }
    
    func submitMathAnswer(_ answer: Int) async -> Bool {
        guard let problem = mathProblem else { return false }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if answer == problem.correctAnswer {
            // Correct answer - log the wake up
            await logWakeUp(correct: true)
            mathProblem = nil
            return true
        } else {
            // Incorrect answer
            return false
        }
    }
    
    private func logWakeUp(correct: Bool) async {
        let now = Date()
        let wakeUp = WakeUpLog(
            id: UUID().uuidString,
            userId: "mock-user-123",
            timestamp: now,
            goalTime: "7:00 AM",
            actualTimeString: DateFormatter.timeOnly.string(from: now),
            mathProblemCorrect: correct,
            shameCount: 0
        )
        
        todaysWakeUp = wakeUp
        mockWakeUps.insert(wakeUp, at: 0)
        recentWakeUps = Array(mockWakeUps.prefix(5))
        
        // Calculate today's score
        await calculateDailyScore()
    }
    
    func calculateDailyScore() async {
        guard let wakeUp = todaysWakeUp else { return }
        
        // Mock scoring calculation
        let wakeUpPoints = Int.random(in: 25...40)
        let consistencyPoints = Int.random(in: 15...30)
        let sleepDurationPoints = Int.random(in: 5...10)
        let totalScore = wakeUpPoints + consistencyPoints + sleepDurationPoints
        
        let score = DailyScore(
            id: UUID().uuidString,
            userId: "mock-user-123",
            date: wakeUp.timestamp,
            score: totalScore,
            wakeUpPoints: wakeUpPoints,
            consistencyPoints: consistencyPoints,
            sleepDurationPoints: sleepDurationPoints,
            shameDeductions: 0
        )
        
        todaysScore = score
        mockScores.insert(score, at: 0)
    }
    
    func addShame(to userId: String) async -> Bool {
        // Simulate adding shame
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Update today's score if it exists
        if todaysScore != nil {
            todaysScore!.shameDeductions += 5
            todaysScore!.score = max(0, todaysScore!.score - 5)
        }
        
        return true
    }
    
    func getWeeklyData() -> [DailyScore] {
        return Array(mockScores.prefix(7))
    }
    
    func getMonthlyData() -> [DailyScore] {
        return mockScores
    }
    
    // MARK: - Shame System
    
    func shameUser(_ targetUserId: String) async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock shame implementation
        print("Mock: Shamed user \(targetUserId)")
        
        // Send mock notification
        await notificationService.sendShameNotification(to: targetUserId, from: "mock-user-123")
        
        isLoading = false
    }
    
    // MARK: - Weekly Data
    
    func getWeeklyScores(userId: String) async -> [DailyScore] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Return mock data
        return Array(mockScores.prefix(7))
    }
    
    func getWeeklyWakeUps(userId: String) async -> [WakeUpLog] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Return mock data
        return Array(mockWakeUps.prefix(7))
    }
}

// MARK: - Date Formatters

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
} 