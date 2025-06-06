//
//  ContentView.swift
//  The Shame Game
//
//  Created by Katie Cheng on 05/06/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var notificationService: NotificationService
    @State private var selectedTab = 0
    @State private var showingMathChallenge = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            if authService.currentUser != nil && authService.user != nil {
                MainTabView(selectedTab: $selectedTab)
            } else {
                AuthenticationView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToFeed)) { _ in
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToShame)) { notification in
            selectedTab = 1 // Friends tab
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @StateObject private var gameService = GameService()
    @StateObject private var friendsService = FriendsService()
    @StateObject private var feedService = FeedService()
    @State private var showingProfile = false
    @State private var showingFriends = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top navigation bar - only show on Feed page
                if selectedTab == 1 {
                    HStack {
                        // App title in center
                        Text("The Shame Game")
                            .font(.custom("Avenir Next", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.primaryText)
                        
                        Spacer()
                        
                        // Navigation buttons
                        HStack(spacing: 12) {
                            // Friends button
                            Button(action: {
                                showingFriends = true
                            }) {
                                Circle()
                                    .fill(Theme.Colors.primaryBlue.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.2.fill")
                                            .foregroundColor(Theme.Colors.primaryText)
                                            .font(.title3)
                                    )
                                    .frame(width: 36, height: 36)
                            }
                            
                            // Profile button
                            Button(action: {
                                showingProfile = true
                            }) {
                                Circle()
                                    .fill(Theme.Colors.primaryBlue.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(Theme.Colors.primaryText)
                                            .font(.title3)
                                    )
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Theme.Colors.cardBackground)
                }
                
                // Main content area with swipe gesture
                ZStack {
                    TabView(selection: $selectedTab) {
                        // Wake Up Tab (default/center)
                        WakeUpView()
                            .environmentObject(gameService)
                            .tag(0)
                        
                        // Feed Tab (swipe left from Wake Up)
                        FeedView()
                            .environmentObject(feedService)
                            .environmentObject(gameService)
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .clipped() // Improve performance by clipping off-screen content
                    
                    // Bottom page indicator
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Wake Up indicator
                            RoundedRectangle(cornerRadius: 3)
                                .fill(selectedTab == 0 ? Theme.Colors.primaryBlue : Theme.Colors.secondaryText.opacity(0.3))
                                .frame(width: selectedTab == 0 ? 30 : 8, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                            
                            // Feed indicator  
                            RoundedRectangle(cornerRadius: 3)
                                .fill(selectedTab == 1 ? Theme.Colors.primaryBlue : Theme.Colors.secondaryText.opacity(0.3))
                                .frame(width: selectedTab == 1 ? 30 : 8, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        }
                        .padding(.bottom, 34) // Account for home indicator
                    }
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingFriends) {
            NavigationView {
                FriendsView()
                    .environmentObject(friendsService)
                    .environmentObject(gameService)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingFriends = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                ProfileView()
                    .environmentObject(gameService)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingProfile = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            loadData()
        }
    }

    
    private func loadData() { 
        Task {
            await gameService.loadTodaysData()
            await friendsService.loadFriends()
            await friendsService.loadPendingRequests()
            await feedService.loadFeed()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
        .environmentObject(NotificationService())
}
