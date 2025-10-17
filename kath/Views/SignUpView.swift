//
//  SignUpView.swift
//  kath
//
//  Created by faheem yousuf malla on 17/10/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var errorMessage: String = ""
    @EnvironmentObject private var model: Model
    private var isFormValid: Bool{
        !email.isEmptyOrWhitespace && !password.isEmptyOrWhitespace && !displayName.isEmptyOrWhitespace
    }
    private func signUp() async{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await model.updateDisplayname(for: result.user, displayName: displayName)
            //temporrary here displayname upfdating
            //await updateDisplayname(user: result.user)
            
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    var body: some View {
        
        Form{
            TextField("Email",text: $email)
                .textInputAutocapitalization(.never)
            SecureField("Password",text: $password)
                .textInputAutocapitalization(.never)
            TextField("Display name",text: $displayName)
            
            HStack{
                Spacer()
                Button("SignUp"){
                    Task{
                        await signUp()
                    }
                }.disabled(!isFormValid)
                    .buttonStyle(.borderless)
                Button("Login"){
                    
                }.buttonStyle(.borderless)
                Spacer()
            }
            Text(errorMessage)
        }
    }
}

#Preview {
    SignUpView().environmentObject(Model())
}
