//
//  Settings.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/10/2021.
//

import SwiftUI

struct Settings: View {
    
    // Declare an environment object
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @State private var notification_all: Bool = true
    @State private var notification_delete: Bool = true
    @State private var notification_insert: Bool = true
    @State private var notification_update: Bool = true
    @AppStorage("dark_mode") private var dark_mode = false
    
    var body: some View {
        VStack {
            List {
                Section(
                    header:
                        Toggle(isOn: $notification_all) {
                            Text("Notifications")
                                .font(.title3)
                                .padding(.vertical)})
                {
                
                    Toggle(isOn: $notification_delete) {
                        Text("On Delete")
                            .font(.title3)
                    }
                    Toggle(isOn: $notification_insert) {
                        Text("On Insert")
                            .font(.title3)
                    }
                    Toggle(isOn: $notification_update) {
                        Text("On Update")
                            .font(.title3)
                    }
                }
                
                Section(header: Text("General").font(.title3).padding(.vertical)) {
                    Picker("Mode", selection: $dark_mode) {
                        Text("Light").tag(false)
                        Text("Dark").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Google Drive").font(.title3).padding(.vertical)) {
                    // Sign In button for Google Drive
                    Button("Sign in") {
                        viewModel.signIn()
                    }
                    
                    // Sign Out Button for Google Srive
                    Button("Sign out") {
                        viewModel.signOut()
                    }
                    
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
