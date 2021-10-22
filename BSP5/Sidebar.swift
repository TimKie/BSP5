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
                    Label("Google Drive", systemImage: "externaldrive")
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
            iCloudDriveView()
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
            
    }
}
