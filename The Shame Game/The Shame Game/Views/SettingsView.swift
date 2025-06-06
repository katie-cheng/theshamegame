import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var notificationService: NotificationService
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                if let user = authService.user {
                    Section {
                        HStack {
                            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Theme.Colors.primaryBlue.opacity(0.3))
                                    .overlay(
                                        Text(user.displayName.prefix(1).uppercased())
                                            .font(Theme.Typography.callout)
                                            .foregroundColor(Theme.Colors.primaryText)
                                    )
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName)
                                    .font(Theme.Typography.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.primaryText)
                                
                                Text(user.email)
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, Theme.Spacing.xs)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Label("Push Notifications", systemImage: "bell")
                            .foregroundColor(Theme.Colors.primaryText)
                        
                        Spacer()
                        
                        if notificationService.isPermissionGranted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Colors.success)
                        } else {
                            Button("Enable") {
                                Task {
                                    await notificationService.requestPermission()
                                }
                            }
                            .foregroundColor(Theme.Colors.primaryBlue)
                        }
                    }
                    
                    Label("Wake-up Notifications", systemImage: "sun.max")
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Label("Shame Notifications", systemImage: "exclamationmark.triangle")
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Label("Friend Activity", systemImage: "person.2")
                        .foregroundColor(Theme.Colors.primaryText)
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundColor(Theme.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    
                    Label("Privacy Policy", systemImage: "doc.text")
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Label("Terms of Service", systemImage: "doc.text")
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Label("Support", systemImage: "questionmark.circle")
                        .foregroundColor(Theme.Colors.primaryText)
                }
                
                // Danger Zone
                Section("Account") {
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Theme.Colors.danger)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authService.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            Task {
                await notificationService.checkPermissionStatus()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
        .environmentObject(NotificationService())
} 