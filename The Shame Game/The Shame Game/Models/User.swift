import Foundation
// Commented out for mock testing
// import FirebaseFirestore

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    let email: String
    var displayName: String
    var sleepGoal: String // e.g., "7:00 AM"
    var bedtimeGoal: String // e.g., "11:00 PM"
    var profileImageURL: String?
    var fcmToken: String?
    let createdAt: Date
    var totalScore: Int
    var currentStreak: Int
    var longestStreak: Int
}

// MARK: - Wake Up Log Model
struct WakeUpLog: Identifiable, Codable {
    let id: String
    let userId: String
    let timestamp: Date
    let goalTime: String
    let actualTimeString: String
    let mathProblemCorrect: Bool
    let shameCount: Int
}

// MARK: - Daily Score Model
struct DailyScore: Identifiable, Codable {
    let id: String
    let userId: String
    let date: Date
    var score: Int
    let wakeUpPoints: Int
    let consistencyPoints: Int
    let sleepDurationPoints: Int
    var shameDeductions: Int
}

// MARK: - Friendship Model
struct Friendship: Identifiable, Codable {
    let id: String
    let userId1: String
    let userId2: String
    let status: String
    let timestamp: Date
}

// MARK: - Shame Event Model
struct ShameEvent: Identifiable, Codable {
    let id: String
    let targetUserId: String
    let shamingUserId: String
    let timestamp: Date
    let pointsDeducted: Int
}

// MARK: - Math Problem Model (moved from GameService for better organization)
struct MathProblem: Identifiable, Codable {
    let id: String = UUID().uuidString
    let operand1: Int
    let operand2: Int
    let operation: MathOperation
    let correctAnswer: Int
    
    var questionText: String {
        return "\(operand1) \(operation.symbol) \(operand2) = ?"
    }
}

enum MathOperation: String, Codable, CaseIterable {
    case addition = "+"
    case subtraction = "-"
    
    var symbol: String {
        return self.rawValue
    }
}

// MARK: - Original Firebase implementation (commented out)
/*
import Foundation
import FirebaseFirestore

// MARK: - User Model
struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var sleepGoal: String // e.g., "7:00 AM"
    var bedtimeGoal: String // e.g., "11:00 PM"
    var profileImageURL: String?
    var fcmToken: String?
    let createdAt: Timestamp
    var totalScore: Int
    var currentStreak: Int
    var longestStreak: Int
}

// MARK: - Wake Up Log Model
struct WakeUpLog: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let timestamp: Timestamp
    let goalTime: String
    let actualTimeString: String
    let mathProblemCorrect: Bool
    let shameCount: Int
}

// MARK: - Daily Score Model
struct DailyScore: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let date: Timestamp
    var score: Int
    let wakeUpPoints: Int
    let consistencyPoints: Int
    let sleepDurationPoints: Int
    var shameDeductions: Int
}

// MARK: - Friendship Model
struct Friendship: Identifiable, Codable {
    @DocumentID var id: String?
    let userId1: String
    let userId2: String
    let status: String
    let timestamp: Timestamp
}

// MARK: - Shame Event Model
struct ShameEvent: Identifiable, Codable {
    @DocumentID var id: String?
    let targetUserId: String
    let shamingUserId: String
    let timestamp: Timestamp
    let pointsDeducted: Int
}

// MARK: - Feed Item Model
struct FeedItem: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let type: FeedItemType
    let message: String
    let timestamp: Timestamp
    var reactions: [String: String] // userId: reactionType
    var comments: [FeedComment]
    let relatedUserId: String? // For shame events
    let shameCount: Int
}

enum FeedItemType: String, Codable, CaseIterable {
    case wakeUp = "wakeUp"
    case shame = "shame"
    case achievement = "achievement"
    
    var emoji: String {
        switch self {
        case .wakeUp: return "🌅"
        case .shame: return "😴"
        case .achievement: return "🏆"
        }
    }
    
    var displayName: String {
        switch self {
        case .wakeUp: return "Wake Up"
        case .shame: return "Shame"
        case .achievement: return "Achievement"
        }
    }
}

// MARK: - Feed Comment Model
struct FeedComment: Identifiable, Codable {
    let id = UUID().uuidString
    let userId: String
    let text: String
    let timestamp: Timestamp
    
    init(userId: String, text: String) {
        self.userId = userId
        self.text = text
        self.timestamp = Timestamp()
    }
}

// MARK: - Math Problem Model
struct MathProblem: Identifiable, Codable {
    let id = UUID().uuidString
    let operand1: Int
    let operand2: Int
    let operation: MathOperation
    let correctAnswer: Int
    
    var questionText: String {
        return "\(operand1) \(operation.symbol) \(operand2) = ?"
    }
    
    static func generate() -> MathProblem {
        let operand1 = Int.random(in: 10...50)
        let operand2 = Int.random(in: 10...50)
        let operation = MathOperation.allCases.randomElement()!
        
        let answer: Int
        switch operation {
        case .addition:
            answer = operand1 + operand2
        case .subtraction:
            // Ensure positive result
            let larger = max(operand1, operand2)
            let smaller = min(operand1, operand2)
            return MathProblem(operand1: larger, operand2: smaller, operation: operation, correctAnswer: larger - smaller)
        }
        
        return MathProblem(operand1: operand1, operand2: operand2, operation: operation, correctAnswer: answer)
    }
}

enum MathOperation: String, Codable, CaseIterable {
    case addition = "+"
    case subtraction = "-"
    
    var symbol: String {
        return self.rawValue
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
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
*/ 