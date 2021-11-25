//
//  BSP5App.swift
//  BSP5
//
//  Created by Tim Kieffer on 11/10/2021.
//

import SwiftUI
import Firebase
import GoogleSignIn


@main
struct BSP5App: App {
    @StateObject var viewModel = GoogleDriveViewModel()
    
    // Firebase Authentication Initializer
    init() {
        setupAuthentication()
      }
    
    // Dark Mode
    @AppStorage("dark_mode") private var dark_mode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(dark_mode ? .dark : .light)
        }
    }
}


extension BSP5App {
    private func setupAuthentication() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().restorePreviousSignIn()
    }
}

