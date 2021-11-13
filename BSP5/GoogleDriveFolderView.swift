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
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @AppStorage("dark_mode") private var dark_mode = false
    
    @State var folderName: String = ""
    @State var showingTextInput = false
    @State var file_data: [GTLRDrive_File] = []
    @State var folder_id : String = ""
    @State var file_history: [GTLRDrive_File]
    @State var isLoaded: Bool = false
    
    var body: some View {
        VStack {
            if isLoaded {
                
                HStack {
                    Spacer()
                    // Create Folder
                    TextField("Enter Folder Name", text: $folderName)
                        .textFieldStyle(.roundedBorder)
                        .border(.black)
                        .fixedSize()
                    Spacer()
                    Button("Create Folder") {
                        viewModel.createFolder(folderName, parent: "1fhPLZra4gmeaH7h2iSK9Kka0DSmTEAae") {(folder, error) in
                            guard let f = folder else {
                                return
                            }
                            print("----------------------------- Created Folder ID:", f)
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    ForEach(file_history.indices, id: \.self) { index in
                        Button(file_history[index].name!){
                            // update files that are listed in the view
                            viewModel.listFiles(file_history[index].identifier!) {(file_list, error) in
                                guard let l = file_list else {
                                    return
                                }
                            
                                file_data = l.files!

                                // remove the correct number of files from the history such that the hisotry still corresponds to displayed file
                                // if the user clicks on the file that is currently displayed, nothing will be removed from the history
                                if index != file_history.count-1 {
                                    for _ in 1...file_history.count-index-1 {
                                        file_history.removeLast()
                                    }
                                }
                            }
                        }
                        .foregroundColor(dark_mode ? Color.white : Color.black)
                        Image(systemName: "greaterthan")
                    }
                }
                
                List(file_data, id: \.self) {file in
                    if file.mimeType == "application/vnd.google-apps.folder" {
                        NavigationLink(destination: GoogleDriveFolderView(file_data: file_data, folder_id: file.identifier!, file_history: file_history)
                        .onAppear{
                            // append file to the history if file is pressed
                            file_history.append(file)
                        }
                        .onDisappear{
                            // remove file from history if "back" button is pressed
                            file_history.removeLast()
                        })
                        {
                            Text(file.name!)
                        }
                    }
                    else {
                        Text(file.name!)
                    }
                }
            }
            
            else {
                ProgressView("Retrieving Files")
            }
        }
        // Call function to get the list of files of the folder that was selected
        .onAppear {
            // DispactchQueue because onAppear loads twice (known error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.listFiles(folder_id) {(file_list, error) in
                    guard let l = file_list else {
                        return
                    }
                    print("------- File List:", l.files!)
                
                    file_data = l.files!
                    
                    isLoaded = true
                }
            }
        }
    }
}

/*
struct GoogleDriveFolderView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleDriveFolderView()
    }
}
*/

