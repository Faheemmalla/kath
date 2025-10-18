
import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct LoginView: View {
    @State private var loginError = ""
    @State private var isLoggedIn = false
    @State private var vm = AuthenticationView()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Image("kathlogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
                VStack(spacing: 15) {
                    Text("Embrace the Beauty")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Learn, Speak & Connect with Kashmiri Language effortlessly.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // MARK: - Google Sign-In Button
                Button(action: {
                    vm.signInWithGoogle()
                }) {
                    HStack(spacing: 20) {
                        Image("googlelogo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Continue with Google")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.gray.opacity(0.35), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 40)
                }
                
                // MARK: - Error Display
                if !loginError.isEmpty {
                    Text(loginError)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .padding(.top, 80)
            .background(
                LinearGradient(
                    colors: [Color.white, Color.blue.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    LoginView()
}
