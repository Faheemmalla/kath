//
//  InitialView.swift
//  kath
//
//  Created by faheem yousuf malla on 18/10/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct InitialView: View {
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    
    
    var body: some View {
        VStack{
            if userLoggedIn{
                LiquidGlassTabView()
            } else {
                LoginView()
            }
            
            
        }.onAppear{
            
            Auth.auth().addStateDidChangeListener{auth, user in
            
                if (user != nil) {
                    
                    userLoggedIn = true
                } else{
                    userLoggedIn = false
                }
            }
        }
    }
}
