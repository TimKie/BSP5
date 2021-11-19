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
    
    @State var showingCreateFolderView = false
    @State var showingImageView = false
    
    @State var folderName: String = ""
    @State var showingTextInput = false
    @State var file_data: [GTLRDrive_File] = []
    @State var folder_id : String = ""
    @State var file_history: [GTLRDrive_File] = []
    @State var isLoaded: Bool = false
    
    var body: some View {
        VStack {
            if isLoaded {
                
                // handle the case where the initial instance of this view is shown
                HStack {
                    Button("Root"){
                        viewModel.listFiles("root") {(file_list, error) in
                            guard let l = file_list else {
                                return
                            }
                        
                            file_data = l.files!
                            
                            // remove all elements in the history as the root folder is the first folder (and not in the history array)
                            file_history.removeAll()
                        }
                    }
                    .foregroundColor(dark_mode ? Color.white : Color.black)
                    Image(systemName: "greaterthan")
                    .onAppear {
                        // do not show the ProgessView when the user is not signed in and no data is displayed
                        isLoaded = true
                    }

                    
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
                    
                
                List {
                    ForEach(file_data.indices, id: \.self) {file_index in
                        if file_data[file_index].mimeType == "application/vnd.google-apps.folder" {
                            NavigationLink(destination: GoogleDriveFolderView(file_data: file_data, folder_id: file_data[file_index].identifier!, file_history: file_history)
                            .onAppear{
                                // append file to the history if file is pressed
                                file_history.append(file_data[file_index])
                            }
                            .onDisappear{
                                // remove file from history if "back" button is pressed
                                file_history.removeLast()
                            })
                            {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(file_data[file_index].name!)
                                }
                            }
                        }
                        else {
                            
                            // For files: a button which calls a pop up view to dispaly the file
                            Button (action: {
                                showingImageView.toggle()
                                if file_data[file_index].webContentLink != nil {
                                    print("-------- Web Content URL:", file_data[file_index].webContentLink!)
                                }
                            }, label: {
                                HStack {
                                    if file_data[file_index].thumbnailLink != nil {
                                        AsyncImage(url: URL(string: file_data[file_index].thumbnailLink!)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            AsyncImage(url: URL(string: file_data[file_index].iconLink!))
                                        }
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        Text(file_data[file_index].name!)
                                    }
                                }
                            })
                            .foregroundColor(Color.black)
                            .sheet(isPresented: $showingImageView) {
                                if file_data[file_index].webContentLink != nil {
                                    ShowImageView(imageLink: file_data[file_index].webContentLink!)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteFile)
                }
            }
            
            else {
                ProgressView("Retrieving Files")
            }
        }
        .navigationBarItems(trailing:
            // Create Folder
            Button(action: {
                showingCreateFolderView.toggle()
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .sheet(isPresented: $showingCreateFolderView, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // update files that are listed in the view (reload view after folder creation such that the folder is displayed in the list)
                    viewModel.listFiles(file_history.last!.identifier!) {(file_list, error) in
                        guard let l = file_list else {
                            return
                        }
                        
                        file_data = l.files!
                    }
                }
            }, content: {
                CreateFolderView(file_history: file_history)
            })
        )
        // Call function to get the list of files of the folder that was selected
        .onAppear {
            // DispactchQueue because onAppear loads twice (known error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.listFiles(folder_id) {(file_list, error) in
                    guard let l = file_list else {
                        return
                    }
                    //print("------- File List:", l.files!)
                
                    file_data = l.files!
                    
                    isLoaded = true
                }
            }
        }
    }
    
    // function to delete an element of the list and call of the function to delete the element also in Google Drive
    func deleteFile(at offsets: IndexSet) {
        offsets.forEach { i in
            viewModel.delete(file_data[i].identifier!) {error in
                guard let error = error else {
                    return
                }
                print("Error when deleting folder/file:", error)
            }
            
            file_data.remove(atOffsets: offsets)
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

