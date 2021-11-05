//
//  GoogleDriveFolderView.swift
//  BSP5
//
//  Created by Tim Kieffer on 05/11/2021.
//

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST


struct GoogleDriveFolderView: View {
    // Declare an environment object
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @State var file_data: [GTLRDrive_File] = []
    @State var folder_id : String = ""
    
    var body: some View {
        
        List(file_data, id: \.self) {file in
            if file.mimeType == "application/vnd.google-apps.folder" {
                NavigationLink(destination: GoogleDriveFolderView(file_data: file_data, folder_id: file.identifier!)) {
                    Text(file.name!)
                }
            }
            else {
                Text(file.name!)
            }
            
        }
        // List the files of the folder which was selected
        .onAppear {
            viewModel.listFiles(folder_id) {(file_list, error) in
                guard let l = file_list else {
                    return
                }
                print("------- File List:", l.files!)
            
                file_data = l.files!
            }
        }
    }
}


struct GoogleDriveFolderView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleDriveFolderView()
    }
}
