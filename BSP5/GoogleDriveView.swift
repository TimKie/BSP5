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
    @State var files: [GTLRDrive_File] = []
    
    // Declare an environment object
    @EnvironmentObject var viewModel: AuthenticationViewModel

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
                
                // navigation with list (only clickable if data is a folder, i.e. mimeType is folder type)
                List(files, id: \.self) {file in
                    if file.mimeType == "application/vnd.google-apps.folder" {
                        NavigationLink(destination: GoogleDriveFolderView(file_data: files, folder_id: file.identifier!, file_history: [file])) {
                            Text(file.name!)
                        }
                    }
                    else {
                        Text(file.name!)
                    }
                }
            }
            .navigationTitle("Google Drive")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.listFilesInFolder("BSP5 TEST Folder") {(file_list, error) in
                guard let l = file_list else {
                    return
                }
                files = l.files!
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
        }
    }
}
