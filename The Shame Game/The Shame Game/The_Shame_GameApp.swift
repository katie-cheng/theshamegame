//
//  The_Shame_GameApp.swift
//  The Shame Game
//
//  Created by Katie Cheng on 05/06/2025.
//

import SwiftUI
// Commented out for mock testing
// import FirebaseCore
// import FirebaseFirestore
// import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Commented out for mock testing
        // FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle device token for push notifications
    }
}

@main
struct The_Shame_GameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(notificationService)
                .preferredColorScheme(.dark) // Force dark mode only
                .onAppear {
                    setupNotifications()
                }
        }
    }
    
    private func setupNotifications() {
        Task {
            await notificationService.requestPermission()
            // Commented out for mock testing
            // await notificationService.saveFCMToken()
        }
    }
}
