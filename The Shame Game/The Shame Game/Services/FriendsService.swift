import Foundation
// Commented out for mock testing
// import FirebaseFirestore

@MainActor
class FriendsService: ObservableObject {
    @Published var friends: [User] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var sentRequests: [FriendRequest] = []
    @Published var searchResults: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mock data
    private var allMockUsers: [User] = []
    
    init() {
        generateMockData()
    }
    
    private func generateMockData() {
        // Create mock users
        allMockUsers = [
            User(
                id: "friend1",
                email: "alice@example.com",
                displayName: "Alice Wonder",
                sleepGoal: "6:30 AM",
                bedtimeGoal: "10:30 PM",
                profileImageURL: nil,
                fcmToken: nil,
                createdAt: Date().addingTimeInterval(-86400 * 15),
                totalScore: 1250,
                currentStreak: 8,
                longestStreak: 15
            ),
            User(
                id: "friend2",
                email: "bob@example.com",
                displayName: "Bob Builder",
                sleepGoal: "7:30 AM",
                bedtimeGoal: "11:00 PM",
                profileImageURL: nil,
                fcmToken: nil,
                createdAt: Date().addingTimeInterval(-86400 * 30),
                totalScore: 890,
                currentStreak: 3,
                longestStreak: 10
            ),
            User(
                id: "friend3",
                email: "charlie@example.com",
                displayName: "Charlie Chocolate",
                sleepGoal: "8:00 AM",
                bedtimeGoal: "11:30 PM",
                profileImageURL: nil,
                fcmToken: nil,
                createdAt: Date().addingTimeInterval(-86400 * 5),
                totalScore: 420,
                currentStreak: 2,
                longestStreak: 5
            ),
            User(
                id: "request1",
                email: "david@example.com",
                displayName: "David Drama",
                sleepGoal: "6:00 AM",
                bedtimeGoal: "10:00 PM",
                profileImageURL: nil,
                fcmToken: nil,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                totalScore: 650,
                currentStreak: 1,
                longestStreak: 7
            ),
            User(
                id: "search1",
                email: "eve@example.com",
                displayName: "Eve Eavesdrop",
                sleepGoal: "7:00 AM",
                bedtimeGoal: "10:45 PM",
                profileImageURL: nil,
                fcmToken: nil,
                createdAt: Date().addingTimeInterval(-86400 * 2),
                totalScore: 180,
                currentStreak: 1,
                longestStreak: 2
            )
        ]
        
        // Set up mock friends (first 2 users)
        friends = Array(allMockUsers.prefix(2))
        
        // Set up mock pending requests
        pendingRequests = [
            FriendRequest(
                id: "req1",
                fromUserId: "request1",
                toUserId: "mock-user-123",
                fromUserDisplayName: "David Drama",
                toUserDisplayName: "Test User",
                status: .pending,
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            )
        ]
    }
    
    func loadFriends() async {
        isLoading = true
        
        // Minimal delay for mock testing
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Mock data is already set up in init
        isLoading = false
    }
    
    func loadPendingRequests() async {
        isLoading = true
        
        // Minimal delay for mock testing
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Mock data is already set up in init
        isLoading = false
    }
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock search - filter users by display name or email
        searchResults = allMockUsers.filter { user in
            user.displayName.lowercased().contains(query.lowercased()) ||
            user.email.lowercased().contains(query.lowercased())
        }.filter { user in
            // Don't show current user or existing friends
            user.id != "mock-user-123" && !friends.contains(where: { $0.id == user.id })
        }
        
        isLoading = false
    }
    
    func sendFriendRequest(to user: User) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock sending friend request
        let request = FriendRequest(
            id: "req-\(UUID().uuidString)",
            fromUserId: "mock-user-123",
            toUserId: user.id,
            fromUserDisplayName: "Test User",
            toUserDisplayName: user.displayName,
            status: .pending,
            timestamp: Date()
        )
        
        // Remove from search results
        searchResults.removeAll { $0.id == user.id }
        
        print("Mock: Sent friend request to \(user.displayName)")
        
        isLoading = false
        return true
    }
    
    func acceptFriendRequest(_ request: FriendRequest) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Find the user and add to friends
        if let user = allMockUsers.first(where: { $0.id == request.fromUserId }) {
            friends.append(user)
        }
        
        // Remove from pending requests
        pendingRequests.removeAll { $0.id == request.id }
        
        print("Mock: Accepted friend request from \(request.fromUserDisplayName)")
        
        isLoading = false
        return true
    }
    
    func rejectFriendRequest(_ request: FriendRequest) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Remove from pending requests
        pendingRequests.removeAll { $0.id == request.id }
        
        print("Mock: Rejected friend request from \(request.fromUserDisplayName)")
        
        isLoading = false
        return true
    }
    
    func removeFriend(_ friend: User) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Remove from friends list
        friends.removeAll { $0.id == friend.id }
        
        print("Mock: Removed friend \(friend.displayName)")
        
        isLoading = false
        return true
    }
    
    func cancelFriendRequest(_ request: FriendRequest) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Remove from sent requests (mock implementation)
        sentRequests.removeAll { $0.id == request.id }
        
        print("Mock: Cancelled friend request to \(request.toUserDisplayName)")
        
        isLoading = false
        return true
    }
    
    func getFriendshipStatus(with userId: String) -> FriendshipStatus {
        // Check if already friends
        if friends.contains(where: { $0.id == userId }) {
            return .friends
        }
        
        // Check if request is pending
        if pendingRequests.contains(where: { $0.fromUserId == userId }) {
            return .pendingIncoming
        }
        
        // Check if we sent a request
        if sentRequests.contains(where: { $0.toUserId == userId }) {
            return .pendingOutgoing
        }
        
        return .none
    }
}

enum FriendshipStatus {
    case none
    case friends
    case pendingIncoming
    case pendingOutgoing
}

// MARK: - FriendRequest Model
struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let fromUserDisplayName: String
    let toUserDisplayName: String
    let status: FriendRequestStatus
    let timestamp: Date
}

enum FriendRequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

// MARK: - Original Firebase implementation (commented out)
/*
import Foundation
import FirebaseFirestore

@MainActor
class FriendsService: ObservableObject {
    @Published var friends: [User] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var searchResults: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func loadFriends() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            // Get friendships where current user is either userId1 or userId2
            let friendships1 = try await db.collection("friendships")
                .whereField("userId1", isEqualTo: currentUserId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            let friendships2 = try await db.collection("friendships")
                .whereField("userId2", isEqualTo: currentUserId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            var friendUserIds: [String] = []
            
            // Collect friend IDs from both directions
            for document in friendships1.documents {
                if let friendship = try? document.data(as: Friendship.self) {
                    friendUserIds.append(friendship.userId2)
                }
            }
            
            for document in friendships2.documents {
                if let friendship = try? document.data(as: Friendship.self) {
                    friendUserIds.append(friendship.userId1)
                }
            }
            
            // Load friend user data
            var loadedFriends: [User] = []
            for friendId in friendUserIds {
                let userDoc = try await db.collection("users").document(friendId).getDocument()
                if let user = try? userDoc.data(as: User.self) {
                    loadedFriends.append(user)
                }
            }
            
            friends = loadedFriends.sorted { $0.displayName < $1.displayName }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadPendingRequests() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            let requestsSnapshot = try await db.collection("friendRequests")
                .whereField("toUserId", isEqualTo: currentUserId)
                .whereField("status", isEqualTo: "pending")
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            pendingRequests = requestsSnapshot.documents.compactMap { doc in
                try? doc.data(as: FriendRequest.self)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        do {
            // Search by display name
            let usersSnapshot = try await db.collection("users")
                .whereField("displayName", isGreaterThanOrEqualTo: query)
                .whereField("displayName", isLessThan: query + "\uf8ff")
                .limit(to: 10)
                .getDocuments()
            
            var results = usersSnapshot.documents.compactMap { doc in
                try? doc.data(as: User.self)
            }
            
            // Filter out current user and existing friends
            let currentUserId = Auth.auth().currentUser?.uid
            let friendIds = Set(friends.map { $0.id })
            
            results = results.filter { user in
                user.id != currentUserId && !friendIds.contains(user.id)
            }
            
            searchResults = results
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func sendFriendRequest(to user: User) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return false }
        
        isLoading = true
        
        do {
            let friendRequest = FriendRequest(
                fromUserId: currentUserId,
                toUserId: user.id,
                fromUserDisplayName: currentUser.displayName ?? "Unknown",
                toUserDisplayName: user.displayName,
                status: .pending,
                timestamp: Timestamp(date: Date())
            )
            
            try await db.collection("friendRequests").addDocument(from: friendRequest)
            
            // Remove from search results
            searchResults.removeAll { $0.id == user.id }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func acceptFriendRequest(_ request: FriendRequest) async -> Bool {
        isLoading = true
        
        do {
            // Create friendship document
            let friendship = Friendship(
                userId1: request.fromUserId,
                userId2: request.toUserId,
                status: "accepted",
                timestamp: Timestamp(date: Date())
            )
            
            // Add friendship
            try await db.collection("friendships").addDocument(from: friendship)
            
            // Update request status
            try await db.collection("friendRequests").document(request.id).updateData([
                "status": "accepted"
            ])
            
            // Remove from pending requests
            pendingRequests.removeAll { $0.id == request.id }
            
            // Reload friends list
            await loadFriends()
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func rejectFriendRequest(_ request: FriendRequest) async -> Bool {
        isLoading = true
        
        do {
            // Update request status
            try await db.collection("friendRequests").document(request.id).updateData([
                "status": "rejected"
            ])
            
            // Remove from pending requests
            pendingRequests.removeAll { $0.id == request.id }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func removeFriend(_ friend: User) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        
        isLoading = true
        
        do {
            // Find and delete the friendship document
            let friendshipsSnapshot = try await db.collection("friendships")
                .whereField("userId1", in: [currentUserId, friend.id])
                .whereField("userId2", in: [currentUserId, friend.id])
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            for document in friendshipsSnapshot.documents {
                try await document.reference.delete()
            }
            
            // Remove from friends list
            friends.removeAll { $0.id == friend.id }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let fromUserId: String
    let toUserId: String
    let fromUserDisplayName: String
    let toUserDisplayName: String
    let status: FriendRequestStatus
    let timestamp: Timestamp
}

enum FriendRequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}
*/ 