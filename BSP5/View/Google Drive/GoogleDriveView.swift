//
//  GoogleDriveView.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/10/2021.
//

import SwiftUI
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


struct GoogleDriveView: View {    
    // Declare an environment object
    @EnvironmentObject var viewModel: GoogleDriveViewModel
    @State var history: [GTLRDrive_File] = []

    @AppStorage("dark_mode") private var dark_mode = false
    
    // Create a constant user to access the current user from the shared instance of GIDSignIn
    private let user = GIDSignIn.sharedInstance().currentUser

    var body: some View {
            VStack {
                HStack {
                    // Access profile picture, username, email address of the user’s Google account
                    NetworkImage(url: user?.profile.imageURL(withDimension: 200))
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100, alignment: .leading)
                        .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(user?.profile.name ?? "")
                            .font(.headline)

                        Text(user?.profile.email ?? "")
                            .font(.subheadline)
                    }

                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)

                // Show a button to access the settings page when the user is not signed in
                if viewModel.state == .signedOut {
                    VStack {
                        Text("Access Settings to Log-In to your Google Account")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.vertical, 20)
    
                        NavigationLink {
                            Settings()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                }
                
                // Calling the GoogleDriveFolderView() which handles the displaying of the folder/files
                // ("root" is the folderID of the root directory of Google Drive)
                if viewModel.state == .signedIn {
                    HStack {
                        Button("My Drive"){
                            viewModel.currentFolder = "root"
                            history.removeAll()
                        }
                        .foregroundColor(dark_mode ? Color.white : Color.black)
                        
                        Image(systemName: "greaterthan")
                        
                        ForEach(0..<history.count, id: \.self) { index in
                            Button(history[index].name ?? ""){
                                if index != history.count-1 {
                                    for _ in 1...history.count-index-1 {
                                        history.removeLast()
                                    }
                                }
                                
                                viewModel.currentFolder = history[index].identifier!
                            }
                            .foregroundColor(dark_mode ? Color.white : Color.black)
                            Image(systemName: "greaterthan")
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                if viewModel.loading && viewModel.state == .signedIn {
                    ProgressView("Retrieving Files")
                } else {
                    GoogleDriveFolderView(currentFolder: $viewModel.currentFolder, files: $viewModel.files, history: $history)
                }
                
                Spacer()
            
            }
            .navigationTitle("Google Drive")
            .navigationBarTitleDisplayMode(.inline) // or .large
            .navigationViewStyle(StackNavigationViewStyle())
        // Restore the SignIn state when the app was closed
        .onAppear {
            GIDSignIn.sharedInstance().restorePreviousSignIn()
            
            viewModel.updateFiles()
            
            // Calling the function to create a notification channel
            viewModel.watchChanges { error in
                guard let error = error else {
                    return
                }
                print("Error when watching file changes: \(error)")
            }
        }
        .onChange(of: viewModel.currentFolder, perform: { _ in
            viewModel.updateFiles()
        })
    }
}

// generic view that is helpful for showing images from the network.
struct NetworkImage: View {
    let url: URL?

    var body: some View {
        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("Login to view content.")
                .padding(.leading)
        }
    }
}
