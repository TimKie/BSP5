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
    @State var showingTextInput = false
    
    @State var deleteFileID: Int? = nil
    @State var createFolder_parentID: String? = nil
    @State var index_of_rename_file: Int? = nil
    
    @Binding var file_history: [GTLRDrive_File]
    @Binding var currentFolderID: String
    @Binding var files: [GTLRDrive_File]
    
    var body: some View {
        if viewModel.state == .signedIn {
            // ------------------------------------- List Folders -------------------------------------
            List {
                ForEach(files.indices, id: \.self) {file_index in
                    if files[file_index].mimeType == "application/vnd.google-apps.folder" {
                        Button {
                            currentFolderID = files[file_index].identifier!
                            file_history.append(files[file_index])
                        } label: {
                            Label(files[file_index].name!, systemImage: "folder")
                            .foregroundColor(dark_mode ? Color.white : Color.black)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteFileID = file_index
                            
                                } label: {
                                    Label("Delete Folder", systemImage: "trash")
                                }
                                
                                Button {
                                    index_of_rename_file = file_index
                                } label: {
                                    Label("Edit Folder Name", systemImage: "pencil")
                                }
                                
                                Button {
                                    createFolder_parentID = files[file_index].identifier!
                                } label: {
                                    Label("Create Folder Inside", systemImage: "folder.badge.plus")
                                }
                            }
                        }
                    }
                    else {
                        
                        // ------------------------------------- List Files + Preview Sheet -------------------------------------
                        
                        // For files: a button which calls a pop up view to dispaly the file
                        Button (action: {
                            showingImageView.toggle()
                            if files[file_index].webContentLink != nil {
                                //print("-------- Web Content URL:", files[file_index].webContentLink!)
                                //print("-------- Web View URL:", files[file_index].webViewLink!)
                            }
                        }, label: {
                            HStack {
                                if files[file_index].thumbnailLink != nil {
                                    // Show the icon for a file until the thumbnail is loaded, then show the thumbnail (on the left side of the file name)
                                    AsyncImage(url: URL(string: files[file_index].thumbnailLink!)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        AsyncImage(url: URL(string: files[file_index].iconLink!))
                                    }
                                    .frame(width: 24, height: 24)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    Text(files[file_index].name!)
                                    .foregroundColor(dark_mode ? Color.white : Color.black)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteFileID = file_index
                                    
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
                        .foregroundColor(.black)
                        .sheet(isPresented: $showingImageView) {
                            if files[file_index].webContentLink != nil {
                                PreviewView(file: files[file_index])
                            }
                        }
                    }
                }
                .onDelete(perform: alertAndDeleteFile)
            }
            .cornerRadius(15)
            .padding(.horizontal)
            // refresh List when pulling down
            .refreshable {
                viewModel.updateFiles(enableProgressView: false)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // ------------------------------------- Folder Creation Sheet -------------------------------------
                                    
                    // Create Folder Button (show the icon only if the user is signed in)
                    if viewModel.state == .signedIn {
                        Button(action: {
                            createFolder_parentID = viewModel.currentFolderID

                        }, label: {
                            Image(systemName: "folder.badge.plus")
                        })
                    }
                }
            }
            // Alert before deleting a file/folder
            .alert(item: $deleteFileID) { item in
                Alert(
                    title: Text("Do you really want to delete the file?"),
                    primaryButton: .destructive(Text("Delete File"), action: {
                        deleteFile(at: IndexSet([item]))
                    }),
                    secondaryButton: .default(Text("Cancel"))
                )
            }
            // Showing sheet to create a folder
            .sheet(item: $createFolder_parentID, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.updateFiles(enableProgressView: true)
                }
            }, content: { item in
                CreateFolderView(parent: createFolder_parentID!)
            })
            // Showing sheet to rename a file
            .sheet(item: $index_of_rename_file, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.updateFiles(enableProgressView: true)
                }
            }, content: { item in
                RenameFileView(file: files[item])
            })
        }
    }
    
    // function to trigger the delete alert also for swiping gesture (for deleting)
    func alertAndDeleteFile(at offsets: IndexSet){
        deleteFileID = offsets.first!
    }
    
    // function to delete an element of the list and call of the function to delete the element also in Google Drive
    func deleteFile(at offsets: IndexSet) {
        offsets.forEach { i in
            viewModel.delete(files[i].identifier!) {error in
                guard let error = error else {
                    return
                }
                print("Error when deleting folder/file:", error)
            }
            
            files.remove(atOffsets: offsets)
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

