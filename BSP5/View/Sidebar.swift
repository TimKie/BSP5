//
//  Sidebar.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/10/2021.
//

import SwiftUI

struct Sidebar: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: iCloudDriveView()) {
                    Label("iCloud Drive", systemImage: "icloud")
                }
                
                NavigationLink(destination: GoogleDriveView()) {
                    Image("google_drive_icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Google Drive")
                }
                
                NavigationLink(destination: DropboxView()) {
                    Label("Dropbox", systemImage: "internaldrive")
                }
                
                Divider()
                
                NavigationLink(destination: Settings()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Cloud Services")
            
            // Default View (before selecting)
            GoogleDriveView()
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
            
    }
}
