import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var friendsService: FriendsService
    @EnvironmentObject var gameService: GameService
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom tab picker
                Picker("Friends Tab", selection: $selectedTab) {
                    Text("Friends").tag(0)
                    Text("Requests").tag(1)
                    Text("Search").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(Theme.Spacing.md)
                
                // Content based on selected tab
                switch selectedTab {
                case 0:
                    friendsList
                case 1:
                    requestsList
                case 2:
                    searchView
                default:
                    EmptyView()
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            Task {
                await friendsService.loadFriends()
                await friendsService.loadPendingRequests()
            }
        }
    }
    
    @ViewBuilder
    private var friendsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                if friendsService.friends.isEmpty && !friendsService.isLoading {
                    emptyFriendsView
                } else {
                    ForEach(friendsService.friends) { friend in
                        FriendCard(
                            user: friend,
                            canShame: gameService.canBeShamed,
                            onShame: {
                                Task {
                                    await gameService.shameUser(friend.id ?? "")
                                }
                            },
                            onRemove: {
                                Task {
                                    await friendsService.removeFriend(friend)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .refreshable {
            Task {
                await friendsService.loadFriends()
            }
        }
    }
    
    @ViewBuilder
    private var requestsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                if !friendsService.pendingRequests.isEmpty {
                    Section {
                        ForEach(friendsService.pendingRequests, id: \.id) { request in
                            FriendRequestCard(
                                request: request,
                                onAccept: {
                                    Task {
                                        await friendsService.acceptFriendRequest(request)
                                    }
                                },
                                onDecline: {
                                    Task {
                                        await friendsService.rejectFriendRequest(request)
                                    }
                                }
                            )
                        }
                    } header: {
                        Text("Pending Requests")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if !friendsService.sentRequests.isEmpty {
                    Section {
                        ForEach(friendsService.sentRequests, id: \.id) { request in
                            SentRequestCard(
                                request: request,
                                onCancel: {
                                    Task {
                                        await friendsService.cancelFriendRequest(request)
                                    }
                                }
                            )
                        }
                    } header: {
                        Text("Sent Requests")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if friendsService.pendingRequests.isEmpty && friendsService.sentRequests.isEmpty && !friendsService.isLoading {
                    emptyRequestsView
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .refreshable {
            Task {
                await friendsService.loadPendingRequests()
            }
        }
    }
    
    @ViewBuilder
    private var searchView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Search bar
            HStack {
                TextField("Search users...", text: $searchText)
                    .themedTextField()
                    .onSubmit {
                        Task {
                            await friendsService.searchUsers(query: searchText)
                        }
                    }
                
                Button("Search") {
                    Task {
                        await friendsService.searchUsers(query: searchText)
                    }
                }
                .primaryButton(isEnabled: !searchText.isEmpty)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            // Search results
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.md) {
                    if friendsService.searchResults.isEmpty && !friendsService.isLoading && !searchText.isEmpty {
                        emptySearchView
                    } else {
                        ForEach(friendsService.searchResults) { user in
                            SearchResultCard(
                                user: user,
                                friendshipStatus: friendsService.getFriendshipStatus(with: user.id ?? ""),
                                onSendRequest: {
                                    Task {
                                        await friendsService.sendFriendRequest(to: user)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
    
    @ViewBuilder
    private var emptyFriendsView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("👥")
                .font(.system(size: 60))
            
            Text("No friends yet")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("Search for friends to start building your shame network!")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Find Friends") {
                selectedTab = 2
            }
            .primaryButton()
        }
        .cardStyle()
        .padding(.top, Theme.Spacing.xxl)
    }
    
    @ViewBuilder
    private var emptyRequestsView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("📮")
                .font(.system(size: 60))
            
            Text("No pending requests")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("Friend requests will appear here")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
        .padding(.top, Theme.Spacing.xxl)
    }
    
    @ViewBuilder
    private var emptySearchView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("🔍")
                .font(.system(size: 60))
            
            Text("No users found")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("Try searching with a different username")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
    }
}

struct FriendCard: View {
    let user: User
    let canShame: Bool
    let onShame: () -> Void
    let onRemove: () -> Void
    @State private var showingActionSheet = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                .overlay(
                    Text(user.displayName.prefix(1).uppercased())
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primaryText)
                )
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(Theme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Score: \(user.totalScore)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Text("Streak: \(user.currentStreak) days")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            if canShame {
                Button("SHAME") {
                    onShame()
                }
                .shameButton()
            }
            
            Button("•••") {
                showingActionSheet = true
            }
            .foregroundColor(Theme.Colors.secondaryText)
        }
        .cardStyle()
        .confirmationDialog("Friend Actions", isPresented: $showingActionSheet) {
            Button("Remove Friend", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct FriendRequestCard: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                .overlay(
                    Text(request.fromUserDisplayName.prefix(1).uppercased())
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primaryText)
                )
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(request.fromUserDisplayName)
                    .font(Theme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Wants to be friends")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            HStack(spacing: Theme.Spacing.sm) {
                Button("Accept") {
                    onAccept()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.Colors.primaryBlue)
                .cornerRadius(6)
                
                Button("Decline") {
                    onDecline()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.Colors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.Colors.secondaryText.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .cardStyle()
    }
}

struct SentRequestCard: View {
    let request: FriendRequest
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                .overlay(
                    Text(request.toUserDisplayName.prefix(1).uppercased())
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primaryText)
                )
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(request.toUserDisplayName)
                    .font(Theme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Request sent")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            Button("Cancel") {
                onCancel()
            }
            .secondaryButton()
        }
        .cardStyle()
    }
}

struct SearchResultCard: View {
    let user: User
    let friendshipStatus: FriendshipStatus
    let onSendRequest: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                .overlay(
                    Text(user.displayName.prefix(1).uppercased())
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.primaryText)
                )
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(Theme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Score: \(user.totalScore)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            switch friendshipStatus {
            case .none:
                Button("Add Friend") {
                    onSendRequest()
                }
                .primaryButton()
            case .pendingIncoming:
                Text("Incoming Request")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.small)
            case .pendingOutgoing:
                Text("Request Sent")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.small)
            case .friends:
                Text("Friends")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.success)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.success.opacity(0.2))
                    .cornerRadius(Theme.CornerRadius.small)
            }
        }
        .cardStyle()
    }
}

#Preview {
    FriendsView()
        .environmentObject(FriendsService())
        .environmentObject(GameService())
} 