//
//  LoginView.swift
//  kath
//
//  Created by faheem yousuf malla on 17/10/25.
//

import SwiftUI
import FirebaseAuth
import Combine

struct LoginView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    private var isFormValid: Bool {
        !email.isEmptyOrWhitespace && !password.isEmptyOrWhitespace
    }

    private func login() async {
        do {
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            // go to the main screen
        } catch {
            print(error.localizedDescription)
        }
    }
    var body: some View{
        Form{
            TextField("Email",text: $email)
                .textInputAutocapitalization(.never)
            SecureField("Password",text: $password)
                .textInputAutocapitalization(.never)
            HStack{
                Spacer()
                Button("Login"){
                    Task{
                        await login()
                    }
                }.disabled(!isFormValid)
                    .buttonStyle(.borderless)
                Button("Register"){
                    
                }.buttonStyle(.borderless)
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
