import Foundation
import UserNotifications
// Commented out for mock testing
// import FirebaseMessaging

@MainActor
class NotificationService: ObservableObject {
    @Published var isPermissionGranted = false
    
    init() {
        checkPermissionStatus()
    }
    
    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isPermissionGranted = granted
            print("Mock: Notification permission granted: \(granted)")
        } catch {
            print("Mock: Error requesting notification permission: \(error)")
        }
    }
    
    func saveFCMToken() async {
        // Mock implementation
        print("Mock: FCM token saved (simulated)")
    }
    
    func notifyFriendsOfWakeUp(userId: String, username: String, time: String) async {
        // Mock implementation
        print("Mock: Notified friends of \(username)'s wake up at \(time)")
    }
    
    func sendShameNotification(to userId: String, from shamingUserId: String) async {
        // Mock implementation
        print("Mock: Sent shame notification to \(userId) from \(shamingUserId)")
    }
    
    func scheduleShameOpportunityNotifications(for friends: [User]) async {
        // Mock implementation
        print("Mock: Scheduled shame opportunity notifications for \(friends.count) friends")
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let navigateToFeed = Notification.Name("navigateToFeed")
    static let navigateToShame = Notification.Name("navigateToShame")
}

// MARK: - Original Firebase implementation (commented out)
/*
import Foundation
import UserNotifications
import FirebaseMessaging

@MainActor
class NotificationService: ObservableObject {
    @Published var isPermissionGranted = false
    
    private let db = Firestore.firestore()
    
    init() {
        checkPermissionStatus()
        setupNotificationHandling()
    }
    
    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isPermissionGranted = granted
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func saveFCMToken() async {
        guard let userId = AuthService().currentUser?.uid else { return }
        
        do {
            let fcmToken = try await Messaging.messaging().token()
            
            try await db.collection("users").document(userId).updateData([
                "fcmToken": fcmToken
            ])
            
            print("FCM token saved: \(fcmToken)")
        } catch {
            print("Error saving FCM token: \(error)")
        }
    }
    
    func notifyFriendsOfWakeUp(userId: String, username: String, time: String) async {
        // Get user's friends
        do {
            let friendshipsSnapshot = try await db.collection("friendships")
                .whereField("userId1", isEqualTo: userId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            let friendships2 = try await db.collection("friendships")
                .whereField("userId2", isEqualTo: userId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            var friendUserIds: [String] = []
            
            // Collect friend IDs from both directions
            for document in friendshipsSnapshot.documents {
                if let friendship = try? document.data(as: Friendship.self) {
                    friendUserIds.append(friendship.userId2)
                }
            }
            
            for document in friendships2.documents {
                if let friendship = try? document.data(as: Friendship.self) {
                    friendUserIds.append(friendship.userId1)
                }
            }
            
            // Send notifications to friends via FCM
            for friendId in friendUserIds {
                await sendPushNotification(
                    to: friendId,
                    title: "🌅 \(username) is awake!",
                    body: "They woke up at \(time) after solving a math problem!",
                    data: ["type": "wakeup", "userId": userId]
                )
            }
            
        } catch {
            print("Error notifying friends: \(error)")
        }
    }
    
    func sendShameNotification(to userId: String, from shamingUserId: String) async {
        do {
            let shamingUserDoc = try await db.collection("users").document(shamingUserId).getDocument()
            let shamingUser = try shamingUserDoc.data(as: User.self)
            
            await sendPushNotification(
                to: userId,
                title: "😴 You've been shamed!",
                body: "\(shamingUser.displayName) thinks you should be awake by now!",
                data: ["type": "shame", "shamingUserId": shamingUserId]
            )
            
        } catch {
            print("Error sending shame notification: \(error)")
        }
    }
    
    func scheduleShameOpportunityNotifications(for friends: [User]) async {
        let calendar = Calendar.current
        let now = Date()
        
        for friend in friends {
            // Parse friend's sleep goal
            let sleepGoalTime = DateFormatter.timeOnly.date(from: friend.sleepGoal) ?? Date()
            let todaySleepGoal = calendar.date(bySettingHour: calendar.component(.hour, from: sleepGoalTime),
                                              minute: calendar.component(.minute, from: sleepGoalTime),
                                              second: 0,
                                              of: now) ?? now
            
            // Schedule notifications every hour from 30 minutes after sleep goal until 12 PM
            let shameStart = todaySleepGoal.addingTimeInterval(30 * 60) // 30 minutes after goal
            let shameEnd = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
            
            var currentTime = shameStart
            var hourCount = 1
            
            while currentTime <= shameEnd && hourCount <= 4 {
                let content = UNMutableNotificationContent()
                content.title = "😴 Shame opportunity!"
                content.body = "\(friend.username) should be awake by now. Send them some shame?"
                content.sound = .default
                content.userInfo = ["type": "shame_opportunity", "friendId": friend.id]
                
                let components = calendar.dateComponents([.hour, .minute], from: currentTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "shame_\(friend.id)_\(hourCount)",
                    content: content,
                    trigger: trigger
                )
                
                try await UNUserNotificationCenter.current().add(request)
                
                currentTime = currentTime.addingTimeInterval(60 * 60) // Add 1 hour
                hourCount += 1
            }
        }
    }
    
    private func sendPushNotification(to userId: String, title: String, body: String, data: [String: String]) async {
        do {
            let userDoc = try await db.collection("users").document(userId).getDocument()
            let user = try userDoc.data(as: User.self)
            
            guard let fcmToken = user.fcmToken else {
                print("No FCM token for user \(userId)")
                return
            }
            
            // In a real implementation, you'd send this to Firebase Cloud Functions
            // which would then send the FCM message. For now, we'll just log it.
            print("Would send FCM to \(fcmToken): \(title) - \(body)")
            
        } catch {
            print("Error sending push notification: \(error)")
        }
    }
    
    private func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func setupNotificationHandling() {
        UNUserNotificationCenter.current().delegate = self
        
        // Handle notification taps
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Handle any pending notifications
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "wakeup":
                NotificationCenter.default.post(name: .navigateToFeed, object: nil)
            case "shame", "shame_opportunity":
                NotificationCenter.default.post(name: .navigateToShame, object: userInfo)
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let navigateToFeed = Notification.Name("navigateToFeed")
    static let navigateToShame = Notification.Name("navigateToShame")
}
*/ 