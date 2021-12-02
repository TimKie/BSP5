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
        NavigationView {
            VStack {
                HStack {
                    // Access profile picture, username, email address of the user’s Google account
                    NetworkImage(url: user?.profile.imageURL(withDimension: 200))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(user?.profile.name ?? "")
                            .font(.headline)

                        Text(user?.profile.email ?? "")
                            .font(.subheadline)
                    }
                    
                    if viewModel.state == .signedOut {
                        Text("Login to view content.")
                    }

                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()

                Spacer()
                
                // Calling the GoogleDriveFolderView() which handles the displaying of the folder/files
                // ("root" is the folderID of the root directory of Google Drive)
                GoogleDriveFolderView(folder_id: "root")
                
                Spacer()
            
            }
            .navigationTitle("Google Drive")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        // Restore the SignIn state when the app was closed
        .onAppear {
            GIDSignIn.sharedInstance().restorePreviousSignIn()
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
        }
    }
}
