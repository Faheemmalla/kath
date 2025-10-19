//
//  LiquidGlassTabView.swift
//  kath
//
//  Created by faheem yousuf malla on 19/10/25.
//

import SwiftUI

enum Tabs {
    case learn, play, scan, search
}

struct LiquidGlassTabView: View {
    @State var selectedTab: Tabs = .learn
    @State var searchString = " "
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "pencil.circle.fill", value: .learn) {
                ContentView()
            }
            Tab("demo", systemImage: "gamecontroller.fill", value: .play) {
                Color.brown.ignoresSafeArea()
            }
            Tab("profile", systemImage: "camera.viewfinder", value: .scan) {
                PremiumProfileView()
            }

            
        }
        .navigationBarBackButtonHidden()
    }
}
#Preview {
    LiquidGlassTabView()
}
