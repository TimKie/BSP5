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
    
    @State var file_history: [GTLRDrive_File] = []
    
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
            
            
            if viewModel.state == .signedIn {
                // ------------------------------------- File History -------------------------------------
                // handle the case where the initial instance of this view is shown
                HStack {
                    Button("MyDrive"){
                        viewModel.currentFolderID = "root"
                        // remove all elements in the history as the root folder is the first folder (and not in the history array)
                        file_history.removeAll()
                        
                    }
                    .foregroundColor(dark_mode ? Color.white : Color.black)
                    
                    Image(systemName: "greaterthan")
                    
                    ForEach(file_history.indices, id: \.self) { index in
                        Button(file_history[index].name ?? ""){
                            // remove the correct number of files from the history such that the hisotry still corresponds to displayed file
                            // if the user clicks on the file that is currently displayed, nothing will be removed from the history
                            if index != file_history.count-1 {
                                for _ in 1...file_history.count-index-1 {
                                    file_history.removeLast()
                                }
                            }
                            
                            viewModel.currentFolderID = file_history[index].identifier!
                            
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
                
                
                // ------------------------------------- Back Button -------------------------------------
                HStack {
                    Button {
                        if !file_history.isEmpty {
                            if file_history.count == 1 {
                                viewModel.currentFolderID = "root"
                            }
                            else {
                                viewModel.currentFolderID = file_history[file_history.count-2].identifier!
                            }
                            file_history.removeLast()
                        }
                    } label: {
                        Label("Back", systemImage: "chevron.backward")
                    }
                    .padding()
                    .frame(maxWidth: 100)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                
            }
            
            if viewModel.state == .signedIn && viewModel.isLoaded {
                // Calling the GoogleDriveFolderView() which handles the displaying of the folder/files
                GoogleDriveFolderView(file_history: $file_history, currentFolderID: $viewModel.currentFolderID, files: $viewModel.files)
            } else {
                Spacer()
                ProgressView("Retrieving Files")
            }
            
            Spacer()
            
        }
        .navigationTitle("Google Drive")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Restore the SignIn state when the app was closed
            GIDSignIn.sharedInstance().restorePreviousSignIn()
            
            // Update the files that are shown
            viewModel.updateFiles(enableProgressView: true)
            
            // Calling the function to create a notification channel
            viewModel.watchChanges { error in
                guard let error = error else {
                    return
                }
                print("Error when watching file changes: \(error)")
            }
        }
        .onChange(of: viewModel.currentFolderID) { _ in
            // Update the files that are shown if the folder that is shown changes
            viewModel.updateFiles(enableProgressView: true)
        }
    }
}

struct GoogleDriveView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleDriveView()
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
