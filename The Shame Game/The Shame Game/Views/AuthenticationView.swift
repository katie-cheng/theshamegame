import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showingError = false
    
    var body: some View {
        GeometryReader { geometry in
            mainContent(geometry: geometry)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(authService.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authService.errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
    }
    
    @ViewBuilder
    private func mainContent(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                appTitle
                authenticationCard
                Spacer(minLength: Theme.Spacing.xl)
            }
            .frame(minHeight: geometry.size.height)
        }
    }
    
    @ViewBuilder
    private var appTitle: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("😴")
                .font(.system(size: 80))
            
            Text("The Shame Game")
                .font(Theme.Typography.largeTitle)
                .foregroundColor(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)
            
            Text("Wake up on time or face the shame!")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Theme.Spacing.xxl)
    }
    
    @ViewBuilder
    private var authenticationCard: some View {
        VStack(spacing: Theme.Spacing.lg) {
            authenticationForm
            
            Divider()
                .background(Theme.Colors.secondaryText)
            
            appleSignInButton
            toggleModeButton
        }
        .cardStyle()
        .padding(.horizontal, Theme.Spacing.lg)
    }
    
    @ViewBuilder
    private var appleSignInButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                // Mock implementation - no special request handling needed
            },
            onCompletion: { result in
                Task {
                    let _ = await authService.signInWithApple()
                }
            }
        )
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    @ViewBuilder
    private var toggleModeButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                isSignUp.toggle()
                clearForm()
            }
        }) {
            toggleModeButtonContent
        }
    }
    
    @ViewBuilder
    private var toggleModeButtonContent: some View {
        HStack {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .foregroundColor(Theme.Colors.secondaryText)
            Text(isSignUp ? "Sign In" : "Sign Up")
                .foregroundColor(Theme.Colors.primaryBlue)
                .fontWeight(.semibold)
        }
        .font(Theme.Typography.callout)
    }
    
    @ViewBuilder
    private var authenticationForm: some View {
        VStack(spacing: Theme.Spacing.md) {
            formTitle
            formFields
            submitButton
        }
    }
    
    @ViewBuilder
    private var formTitle: some View {
        Text(isSignUp ? "Create Account" : "Welcome Back")
            .font(Theme.Typography.title2)
            .foregroundColor(Theme.Colors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var formFields: some View {
        // Username field (only for sign up)
        if isSignUp {
            usernameField
        }
        
        emailField
        passwordField
        
        // Confirm password field (only for sign up)
        if isSignUp {
            confirmPasswordField
        }
    }
    
    @ViewBuilder
    private var usernameField: some View {
        TextField("Username", text: $username)
            .themedTextField()
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
    
    @ViewBuilder
    private var emailField: some View {
        TextField("Email", text: $email)
            .themedTextField()
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
    
    @ViewBuilder
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .themedTextField()
    }
    
    @ViewBuilder
    private var confirmPasswordField: some View {
        SecureField("Confirm Password", text: $confirmPassword)
            .themedTextField()
    }
    
    @ViewBuilder
    private var submitButton: some View {
        Button(action: handleSubmit) {
            submitButtonContent
        }
        .primaryButton(isEnabled: isFormValid && !authService.isLoading)
    }
    
    @ViewBuilder
    private var submitButtonContent: some View {
        HStack {
            if authService.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primaryText))
                    .scaleEffect(0.8)
            }
            Text(isSignUp ? "Sign Up" : "Sign In")
        }
        .frame(maxWidth: .infinity)
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !username.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleSubmit() {
        Task {
            let success: Bool
            if isSignUp {
                success = await authService.signUp(email: email, password: password, displayName: username)
            } else {
                success = await authService.signIn(email: email, password: password)
            }
            
            if success {
                // Authentication succeeded, form will be dismissed automatically
                // when authService.currentUser is set
                clearForm()
            }
            // Error handling is done in AuthService via errorMessage
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        username = ""
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthService())
} 