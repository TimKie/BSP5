//
//  Settings.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/10/2021.
//

import SwiftUI

struct Settings: View {
    
    // Declare an environment object
    @EnvironmentObject var viewModel: GoogleDriveViewModel
    
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
                
                Section(header: Text("Appearance").font(.title3).padding(.vertical)) {
                    Picker("Mode", selection: $dark_mode) {
                        Text("Light").tag(false)
                        Text("Dark").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Google Drive").font(.title3).padding(.vertical)) {
                    // Sign In button for Google Drive
                    Button {
                        viewModel.signIn()
                    } label: {
                        HStack {
                            Image("google_icon")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Sign In")
                                .foregroundColor(dark_mode ? Color.white : Color.black)
                        }
                    }
        
                    // Sign Out Button for Google Srive
                    Button {
                        viewModel.signOut()
                    } label: {
                        HStack {
                            Image("google_icon")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Sign Out")
                                .foregroundColor(dark_mode ? Color.white : Color.black)
                        }
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
