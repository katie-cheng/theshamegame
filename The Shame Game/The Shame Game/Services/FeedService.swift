import Foundation
// Commented out for mock testing
// import FirebaseFirestore

@MainActor
class FeedService: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        generateMockFeed()
    }
    
    private func generateMockFeed() {
        let calendar = Calendar.current
        let now = Date()
        
        feedItems = [
            FeedItem(
                id: "feed1",
                userId: "friend1",
                userName: "Alice Wonder",
                type: .wakeUp,
                message: "Alice Wonder woke up at 6:45 AM after solving MATH! Big brain energy. 🧠",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
                reactions: [
                    FeedReaction(id: "r1", userId: "friend2", userName: "Bob Builder", type: .applause),
                    FeedReaction(id: "r2", userId: "mock-user-123", userName: "Test User", type: .fire)
                ],
                comments: [
                    FeedComment(id: "c1", userId: "friend2", userName: "Bob Builder", message: "Nice work! 👏", timestamp: calendar.date(byAdding: .hour, value: -1, to: now)!)
                ],
                shameCount: 0
            ),
            FeedItem(
                id: "feed2",
                userId: "friend2",
                userName: "Bob Builder",
                type: .shame,
                message: "Bob Builder got SHAMED by Alice Wonder. Still sleeping at 8:30 AM? 😴",
                timestamp: calendar.date(byAdding: .hour, value: -4, to: now)!,
                reactions: [
                    FeedReaction(id: "r3", userId: "friend1", userName: "Alice Wonder", type: .muscle)
                ],
                comments: [],
                shameCount: 1
            ),
            FeedItem(
                id: "feed3",
                userId: "mock-user-123",
                userName: "Test User",
                type: .wakeUp,
                message: "Test User woke up at 7:15 AM after solving MATH! Ready to conquer the day! 🌅",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                reactions: [
                    FeedReaction(id: "r4", userId: "friend1", userName: "Alice Wonder", type: .applause),
                    FeedReaction(id: "r5", userId: "friend2", userName: "Bob Builder", type: .muscle)
                ],
                comments: [
                    FeedComment(id: "c2", userId: "friend1", userName: "Alice Wonder", message: "Great job! 🎉", timestamp: calendar.date(byAdding: .day, value: -1, to: now)!)
                ],
                shameCount: 0
            ),
            FeedItem(
                id: "feed4",
                userId: "friend3",
                userName: "Charlie Chocolate",
                type: .wakeUp,
                message: "Charlie Chocolate woke up at 8:30 AM after solving MATH! Better late than never! ⏰",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now)!,
                reactions: [],
                comments: [],
                shameCount: 0
            )
        ]
    }
    
    func loadFeed() async {
        isLoading = true
        
        // Minimal delay for mock testing
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Mock data is already generated
        isLoading = false
    }
    
    func addReaction(to feedItem: FeedItem, type: ReactionType) async -> Bool {
        guard let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) else {
            return false
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Check if user already reacted
        let existingReactionIndex = feedItems[index].reactions.firstIndex { reaction in
            reaction.userId == "mock-user-123"
        }
        
        if let existingIndex = existingReactionIndex {
            // Update existing reaction
            feedItems[index].reactions[existingIndex].type = type
        } else {
            // Add new reaction
            let newReaction = FeedReaction(
                id: UUID().uuidString,
                userId: "mock-user-123",
                userName: "Test User",
                type: type
            )
            feedItems[index].reactions.append(newReaction)
        }
        
        print("Mock: Added \(type.emoji) reaction to \(feedItem.userName)'s post")
        return true
    }
    
    func removeReaction(from feedItem: FeedItem) async -> Bool {
        guard let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) else {
            return false
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Remove user's reaction
        feedItems[index].reactions.removeAll { reaction in
            reaction.userId == "mock-user-123"
        }
        
        print("Mock: Removed reaction from \(feedItem.userName)'s post")
        return true
    }
    
    func addComment(to feedItem: FeedItem, message: String) async -> Bool {
        guard let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) else {
            return false
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        let newComment = FeedComment(
            id: UUID().uuidString,
            userId: "mock-user-123",
            userName: "Test User",
            message: message,
            timestamp: Date()
        )
        
        feedItems[index].comments.append(newComment)
        
        print("Mock: Added comment '\(message)' to \(feedItem.userName)'s post")
        return true
    }
    
    func shameFriend(_ friend: User) async -> Bool {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Create a shame feed item
        let shameFeedItem = FeedItem(
            id: UUID().uuidString,
            userId: friend.id,
            userName: friend.displayName,
            type: .shame,
            message: "\(friend.displayName) got SHAMED by Test User. Still sleeping? 😴",
            timestamp: Date(),
            reactions: [],
            comments: [],
            shameCount: 1
        )
        
        // Add to beginning of feed
        feedItems.insert(shameFeedItem, at: 0)
        
        print("Mock: Shamed \(friend.displayName)")
        return true
    }
    
    func getUserReaction(for feedItem: FeedItem) -> FeedReaction? {
        return feedItem.reactions.first { reaction in
            reaction.userId == "mock-user-123"
        }
    }
    
    func getPresetComments() -> [String] {
        return [
            "Nice work! 💪",
            "Keep it up! 🔥",
            "Great job! 👏",
            "Awesome! 🎉",
            "You got this! 💯"
        ]
    }
}

// MARK: - Models
struct FeedItem: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let type: FeedItemType
    let message: String
    let timestamp: Date
    var reactions: [FeedReaction]
    var comments: [FeedComment]
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
}

struct FeedReaction: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    var type: ReactionType
}

enum ReactionType: String, Codable, CaseIterable {
    case applause = "applause"
    case muscle = "muscle"
    case fire = "fire"
    
    var emoji: String {
        switch self {
        case .applause: return "👏"
        case .muscle: return "💪"
        case .fire: return "🔥"
        }
    }
    
    var label: String {
        switch self {
        case .applause: return "Applaud"
        case .muscle: return "Strong"
        case .fire: return "Fire"
        }
    }
}

struct FeedComment: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let message: String
    let timestamp: Date
}

// MARK: - Original Firebase implementation (commented out)
/*
import Foundation
import FirebaseFirestore

@MainActor
class FeedService: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func loadFeed() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            // Get current user's friends
            let friendsService = FriendsService()
            await friendsService.loadFriends()
            let friendIds = friendsService.friends.compactMap { $0.id }
            
            // Include current user in the feed
            var userIds = friendIds
            userIds.append(currentUserId)
            
            // Get feed items for friends and current user
            let feedSnapshot = try await db.collection("feedItems")
                .whereField("userId", in: userIds)
                .order(by: "timestamp", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            feedItems = feedSnapshot.documents.compactMap { doc in
                try? doc.data(as: FeedItem.self)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addReaction(to feedItem: FeedItem, type: ReactionType) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return false }
        
        do {
            let reaction = FeedReaction(
                userId: currentUserId,
                userName: currentUser.displayName ?? "Unknown",
                type: type,
                timestamp: Timestamp(date: Date())
            )
            
            // Add reaction to subcollection
            try await db.collection("feedItems")
                .document(feedItem.id)
                .collection("reactions")
                .document(currentUserId)
                .setData(from: reaction)
            
            // Update local data
            if let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                // Remove existing reaction if any
                feedItems[index].reactions.removeAll { $0.userId == currentUserId }
                // Add new reaction
                feedItems[index].reactions.append(reaction)
            }
            
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func removeReaction(from feedItem: FeedItem) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            // Remove reaction from subcollection
            try await db.collection("feedItems")
                .document(feedItem.id)
                .collection("reactions")
                .document(currentUserId)
                .delete()
            
            // Update local data
            if let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                feedItems[index].reactions.removeAll { $0.userId == currentUserId }
            }
            
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func addComment(to feedItem: FeedItem, message: String) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return false }
        
        do {
            let comment = FeedComment(
                userId: currentUserId,
                userName: currentUser.displayName ?? "Unknown",
                message: message,
                timestamp: Timestamp(date: Date())
            )
            
            // Add comment to subcollection
            try await db.collection("feedItems")
                .document(feedItem.id)
                .collection("comments")
                .addDocument(from: comment)
            
            // Update local data
            if let index = feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                feedItems[index].comments.append(comment)
            }
            
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func shameFriend(_ friend: User) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return false }
        
        do {
            // Create shame event
            let shameEvent = ShameEvent(
                targetUserId: friend.id,
                shamingUserId: currentUserId,
                timestamp: Timestamp(date: Date()),
                pointsDeducted: 5
            )
            
            try await db.collection("shameEvents").addDocument(from: shameEvent)
            
            // Create feed item
            let feedItem = FeedItem(
                userId: friend.id,
                userName: friend.displayName,
                type: .shame,
                message: "\(friend.displayName) got SHAMED by \(currentUser.displayName ?? "Someone"). Still sleeping? 😴",
                timestamp: Timestamp(date: Date()),
                reactions: [],
                comments: [],
                shameCount: 1
            )
            
            try await db.collection("feedItems").addDocument(from: feedItem)
            
            // Update local feed
            feedItems.insert(feedItem, at: 0)
            
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func getUserReaction(for feedItem: FeedItem) -> FeedReaction? {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return nil }
        return feedItem.reactions.first { $0.userId == currentUserId }
    }
}

struct FeedItem: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let type: FeedItemType
    let message: String
    let timestamp: Timestamp
    var reactions: [FeedReaction]
    var comments: [FeedComment]
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
}

struct FeedReaction: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let type: ReactionType
    let timestamp: Timestamp
}

enum ReactionType: String, Codable, CaseIterable {
    case applause = "applause"
    case muscle = "muscle"
    case fire = "fire"
    
    var emoji: String {
        switch self {
        case .applause: return "👏"
        case .muscle: return "💪"
        case .fire: return "🔥"
        }
    }
    
    var label: String {
        switch self {
        case .applause: return "Applaud"
        case .muscle: return "Strong"
        case .fire: return "Fire"
        }
    }
}

struct FeedComment: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let message: String
    let timestamp: Timestamp
}
*/ 