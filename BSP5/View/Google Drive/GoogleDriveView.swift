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
                
                Spacer()
                
                // Calling the GoogleDriveFolderView() which handles the displaying of the folder/files
                // ("root" is the folderID of the root directory of Google Drive)
                GoogleDriveFolderView(folder_id: "root")
                
                //Spacer()
            
            }
            .navigationTitle("Google Drive")
            .navigationBarTitleDisplayMode(.inline) // or .large
            .navigationViewStyle(StackNavigationViewStyle())
        // Restore the SignIn state when the app was closed
        .onAppear {
            GIDSignIn.sharedInstance().restorePreviousSignIn()
            
            // Calling the function to create a notification channel
            viewModel.watchChanges { error in
                guard let error = error else {
                    return
                }
                print("Error when watching file changes: \(error)")
            }
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
