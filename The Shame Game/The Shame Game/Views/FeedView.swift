import SwiftUI

// Global helper function for time formatting
private func timeAgoSince(_ date: Date) -> String {
    let now = Date()
    let timeInterval = now.timeIntervalSince(date)
    
    if timeInterval < 60 {
        return "now"
    } else if timeInterval < 3600 {
        let minutes = Int(timeInterval / 60)
        return "\(minutes)m"
    } else if timeInterval < 86400 {
        let hours = Int(timeInterval / 3600)
        return "\(hours)h"
    } else {
        let days = Int(timeInterval / 86400)
        return "\(days)d"
    }
}

struct FeedView: View {
    @EnvironmentObject var feedService: FeedService
    @EnvironmentObject var gameService: GameService
    @State private var showingCommentModal = false
    @State private var selectedFeedItem: FeedItem?
    @State private var commentText = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                if feedService.feedItems.isEmpty && !feedService.isLoading {
                    emptyStateView
                } else {
                    ForEach(feedService.feedItems) { item in
                        FeedItemCard(
                            item: item,
                            onReaction: { type in
                                Task {
                                    await feedService.addReaction(to: item, type: type)
                                }
                            },
                            onComment: {
                                selectedFeedItem = item
                                showingCommentModal = true
                            },
                            onShame: {
                                // For shame posts, we don't need to add more shame
                                print("Shame button tapped for \(item.userName)")
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.sm)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .refreshable {
            Task {
                await feedService.loadFeed()
            }
        }
        .sheet(isPresented: $showingCommentModal) {
            commentModal
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                await feedService.loadFeed()
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("📱")
                .font(.system(size: 60))
            
            Text("No posts yet")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("Add some friends and start waking up to see your feed come alive!")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
        .padding(.top, Theme.Spacing.xxl)
    }
    
    @ViewBuilder
    private var commentModal: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                if let item = selectedFeedItem {
                    // Post preview
                    VStack(spacing: Theme.Spacing.md) {
                        HStack {
                            Circle()
                                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                                .overlay(
                                    Text(item.userName.prefix(1).uppercased())
                                        .font(Theme.Typography.callout)
                                        .foregroundColor(Theme.Colors.primaryText)
                                )
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.userName)
                                    .font(Theme.Typography.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.primaryText)
                                
                                Text(timeAgoSince(item.timestamp))
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                        }
                        
                        Text(item.message)
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .cardStyle()
                    
                    // Comments section
                    if !item.comments.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: Theme.Spacing.md) {
                                ForEach(item.comments, id: \.id) { comment in
                                    CommentRow(comment: comment)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.sm)
                        }
                        .frame(maxHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .fill(Theme.Colors.cardBackground.opacity(0.5))
                        )
                    } else {
                        Text("No comments yet")
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .fill(Theme.Colors.cardBackground.opacity(0.5))
                            )
                    }
                    
                    // Preset comments
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(feedService.getPresetComments(), id: \.self) { preset in
                                Button(preset) {
                                    commentText = preset
                                    submitComment()
                                }
                                .secondaryButton()
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                    
                    // Custom comment
                    HStack {
                        TextField("Add a comment...", text: $commentText)
                            .themedTextField()
                        
                        Button("Send") {
                            submitComment()
                        }
                        .primaryButton(isEnabled: !commentText.isEmpty)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingCommentModal = false
                    }
                }
            }
        }
    }
    
    private func submitComment() {
        guard !commentText.isEmpty,
              let item = selectedFeedItem else { return }
        
        Task {
            await feedService.addComment(to: item, message: commentText)
            commentText = ""
        }
    }
}

struct FeedItemCard: View {
    let item: FeedItem
    let onReaction: (ReactionType) -> Void
    let onComment: () -> Void
    let onShame: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Header
            HStack {
                Circle()
                    .fill(Theme.Colors.primaryBlue.opacity(0.3))
                    .overlay(
                        Text(item.userName.prefix(1).uppercased())
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.primaryText)
                    )
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.userName)
                        .font(Theme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text(timeAgoSince(item.timestamp))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Shame button for shame posts
                if item.type == .shame {
                    Button("💸") {
                        onShame()
                    }
                    .font(.title2)
                }
            }
            
            // Content
            Text(item.message)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Reactions bar
            HStack {
                ForEach(ReactionType.allCases, id: \.self) { reactionType in
                    Button(action: {
                        onReaction(reactionType)
                    }) {
                        HStack(spacing: 4) {
                            Text(reactionType.emoji)
                            
                            let count = item.reactions.filter { $0.type == reactionType }.count
                            if count > 0 {
                                Text("\(count)")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(
                            item.reactions.contains { $0.userId == "mock-user-123" && $0.type == reactionType } ?
                                Theme.Colors.primaryBlue.opacity(0.2) : Color.clear
                        )
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                }
                
                Spacer()
                
                Button(action: onComment) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(item.comments.count)")
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .cardStyle()
    }
}

struct CommentRow: View {
    let comment: FeedComment
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.3))
                .overlay(
                    Text(comment.userName.prefix(1).uppercased())
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primaryText)
                )
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(comment.userName)
                        .font(Theme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text(timeAgoSince(comment.timestamp))
                        .font(Theme.Typography.caption2)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Text(comment.message)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            
            Spacer()
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(FeedService())
        .environmentObject(GameService())
} 