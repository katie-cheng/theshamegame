import SwiftUI
import Foundation
// Commented out for mock testing
// import FirebaseAuth
// import FirebaseFirestore
// import AuthenticationServices
// import CryptoKit

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: MockFirebaseUser?
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mock Firebase User
    class MockFirebaseUser {
        let uid: String
        let email: String?
        
        init(uid: String, email: String?) {
            self.uid = uid
            self.email = email
        }
    }
    
    init() {
        // For mock testing, automatically sign in with a dummy user
        signInWithMockUser()
    }
    
    func signInWithMockUser() {
        currentUser = MockFirebaseUser(uid: "mock-user-123", email: "test@example.com")
        user = User(
            id: "mock-user-123",
            email: "test@example.com",
            displayName: "Test User",
            sleepGoal: "7:00 AM",
            bedtimeGoal: "11:00 PM",
            profileImageURL: nil,
            fcmToken: nil,
            createdAt: Date(),
            totalScore: 850,
            currentStreak: 5,
            longestStreak: 12
        )
    }
    
    func signUp(email: String, password: String, displayName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock successful signup
        currentUser = MockFirebaseUser(uid: "mock-user-\(Int.random(in: 1000...9999))", email: email)
        user = User(
            id: currentUser!.uid,
            email: email,
            displayName: displayName,
            sleepGoal: "7:00 AM",
            bedtimeGoal: "11:00 PM",
            profileImageURL: nil,
            fcmToken: nil,
            createdAt: Date(),
            totalScore: 0,
            currentStreak: 0,
            longestStreak: 0
        )
        
        isLoading = false
        return true
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock successful signin
        currentUser = MockFirebaseUser(uid: "mock-user-signin", email: email)
        user = User(
            id: currentUser!.uid,
            email: email,
            displayName: "Returning User",
            sleepGoal: "7:00 AM",
            bedtimeGoal: "11:00 PM",
            profileImageURL: nil,
            fcmToken: nil,
            createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            totalScore: 450,
            currentStreak: 3,
            longestStreak: 8
        )
        
        isLoading = false
        return true
    }
    
    func signInWithApple() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock Apple sign in
        currentUser = MockFirebaseUser(uid: "mock-apple-user", email: "apple@example.com")
        user = User(
            id: currentUser!.uid,
            email: "apple@example.com",
            displayName: "Apple User",
            sleepGoal: "7:00 AM",
            bedtimeGoal: "11:00 PM",
            profileImageURL: nil,
            fcmToken: nil,
            createdAt: Date(),
            totalScore: 120,
            currentStreak: 1,
            longestStreak: 1
        )
        
        isLoading = false
        return true
    }
    
    func signOut() {
        currentUser = nil
        user = nil
        errorMessage = nil
    }
    
    func updateProfile(displayName: String, sleepGoal: String, bedtimeGoal: String) async -> Bool {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock update
        user?.displayName = displayName
        user?.sleepGoal = sleepGoal
        user?.bedtimeGoal = bedtimeGoal
        
        isLoading = false
        return true
    }
    
    private func checkAuthState() {
        // Mock implementation - already handled in init
    }
    
    private func loadUserData() async {
        // Mock implementation - already handled in sign in methods
    }
    
    private func createUserDocument(_ firebaseUser: MockFirebaseUser, displayName: String) async -> Bool {
        // Mock implementation
        return true
    }
}

// MARK: - Original Firebase implementation (commented out)
/*
import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var currentNonce: String?
    
    init() {
        checkAuthState()
    }
    
    func signUp(email: String, password: String, displayName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let success = await createUserDocument(result.user, displayName: displayName)
            
            if success {
                await loadUserData()
            }
            
            isLoading = false
            return success
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            await loadUserData()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func signInWithApple() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let nonce = randomNonceString()
            currentNonce = nonce
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            // This would need proper delegation implementation
            // For now, we'll simulate success
            await Task.sleep(nanoseconds: 1_000_000_000)
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            user = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(displayName: String, sleepGoal: String, bedtimeGoal: String) async -> Bool {
        guard let userId = currentUser?.uid else { return false }
        
        isLoading = true
        
        do {
            try await db.collection("users").document(userId).updateData([
                "displayName": displayName,
                "sleepGoal": sleepGoal,
                "bedtimeGoal": bedtimeGoal
            ])
            
            user?.displayName = displayName
            user?.sleepGoal = sleepGoal
            user?.bedtimeGoal = bedtimeGoal
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    private func checkAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                if user != nil {
                    await self?.loadUserData()
                }
            }
        }
    }
    
    private func loadUserData() async {
        guard let userId = currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                user = try Firestore.Decoder().decode(User.self, from: data)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func createUserDocument(_ firebaseUser: FirebaseAuth.User, displayName: String) async -> Bool {
        let newUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: displayName,
            sleepGoal: "7:00 AM",
            bedtimeGoal: "11:00 PM",
            profileImageURL: nil,
            fcmToken: nil,
            createdAt: Date(),
            totalScore: 0,
            currentStreak: 0,
            longestStreak: 0
        )
        
        do {
            let data = try Firestore.Encoder().encode(newUser)
            try await db.collection("users").document(firebaseUser.uid).setData(data)
            user = newUser
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
*/ 