//
//  kathApp.swift
//  kath
//
//  Created by faheem yousuf malla on 18/10/25.
//

//
//  GoogleSignInFirebaseSwiftUIApp.swift
//  GoogleSignInFirebaseSwiftUI
//
//  Created by Sheehan Munim on 6/9/24.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

@main
struct kathApp: App {
    
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            InitialView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        FirebaseApp.configure()
        return true
    }
    
    @available(iOS 9.0, *)
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    
}
