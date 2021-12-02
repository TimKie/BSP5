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
    @EnvironmentObject var viewModel: GoogleDriveViewModel
    
    @AppStorage("dark_mode") private var dark_mode = false
    
    @State var showingCreateFolderView = false
    @State var showingImageView = false
    
    let listRowHeight = 55
    
    @State var createFolder_parentID: String? = nil
    @State var index_of_rename_file: Int? = nil
    @State var folderName: String = ""
    @State var showingTextInput = false
    @State var file_data: [GTLRDrive_File] = []
    @State var folder_id : String = ""
    @State var file_history: [GTLRDrive_File] = []
    @State var isLoaded: Bool = false
    
    var body: some View {
        VStack {
            if isLoaded && viewModel.state == .signedIn {
                
                // ------------------------------------- File History -------------------------------------
                
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
                
                // ------------------------------------- List Folders -------------------------------------
                
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
                                Label(file_data[file_index].name!, systemImage: "folder")
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteFile(at: IndexSet([file_index]))
                                    } label: {
                                        Label("Delete Folder", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        index_of_rename_file = file_index
                                    } label: {
                                        Label("Edit Folder Name", systemImage: "pencil")
                                    }
                                    
                                    Button {
                                        createFolder_parentID = file_data[file_index].identifier!
                                    } label: {
                                        Label("Create Folder Inside", systemImage: "folder.badge.plus")
                                    }
                                }
                            }
                        }
                        else {
                            
                            // ------------------------------------- Lis Files + Preview Sheet -------------------------------------
                            
                            // For files: a button which calls a pop up view to dispaly the file
                            Button (action: {
                                showingImageView.toggle()
                                if file_data[file_index].webContentLink != nil {
                                    print("-------- Web Content URL:", file_data[file_index].webContentLink!)
                                    print("-------- Web View URL:", file_data[file_index].webViewLink!)
                                }
                            }, label: {
                                HStack {
                                    if file_data[file_index].thumbnailLink != nil {
                                        // Show the icon for a file until the thumbnail is loaded, then show the thumbnail (on the left side of the file name)
                                        AsyncImage(url: URL(string: file_data[file_index].thumbnailLink!)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            AsyncImage(url: URL(string: file_data[file_index].iconLink!))
                                        }
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        Text(file_data[file_index].name!)
                                        .foregroundColor(dark_mode ? Color.white : Color.black)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteFile(at: IndexSet([file_index]))
                                            } label: {
                                                Label("Delete File", systemImage: "trash")
                                            }

                                            Button {
                                                index_of_rename_file = file_index
                                            } label: {
                                                Label("Edit File Name", systemImage: "pencil")
                                            }
                                            
                                            Button {
                                                showingImageView.toggle()
                                            } label: {
                                                Label("Show Preview of File", systemImage: "eye")
                                            }
                                        }
                                    }
                                }
                            })
                            .foregroundColor(Color.black)
                            .sheet(isPresented: $showingImageView) {
                                if file_data[file_index].webContentLink != nil {
                                    PreviewView(file: file_data[file_index])
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteFile)
                }
                .sheet(item: $index_of_rename_file, onDismiss: {
                    updateList()
                }, content: { item in
                    RenameFileView(file: file_data[item])
                })
            }
            else {
                if viewModel.state == .signedIn {
                    ProgressView("Retrieving Files")
                }
            }
        }
        .navigationBarItems(trailing:
                                
            // ------------------------------------- Folder Creation Sheet -------------------------------------
                            
            // Create Folder (show the icon only if the user is signed in)
            viewModel.state == .signedIn ? Button(action: {
                if file_history.isEmpty {
                    createFolder_parentID = "root"
                }
                else {
                    createFolder_parentID = file_history.last!.identifier!
                }
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .sheet(item: $createFolder_parentID, onDismiss: {
                updateList()
            }, content: { item in
                CreateFolderView(parent: item)
            })
            // if the user is not signed in -> show nothing
            : nil
        )
        
        // ------------------------------------- Function Call -------------------------------------
        
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
    
    // function to update the files that are listed after folder creation or file renaming
    func updateList() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // update files that are listed in the view (reload view after folder creation such that the folder is displayed in the list)
            if file_history.isEmpty {
                viewModel.listFiles("root") {(file_list, error) in
                    guard let l = file_list else {
                        return
                    }
                    
                    file_data = l.files!
                }
            }
            else {
                viewModel.listFiles(file_history.last!.identifier!) {(file_list, error) in
                    guard let l = file_list else {
                        return
                    }
                    
                    file_data = l.files!
                }
            }
        }
    }
    
}


// Int must conform to identifiable to be used as sheet item (renaming file)
extension Int: Identifiable {
    public var id: Int { self }
}

extension String: Identifiable {
    public var id: String { self }
}


/*
struct GoogleDriveFolderView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleDriveFolderView()
    }
}
*/

