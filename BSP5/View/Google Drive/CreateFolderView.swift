//
//  CreateFolderView.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/11/2021.
//

import SwiftUI
import GoogleAPIClientForREST

struct CreateFolderView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: AuthenticationViewModel

    @State var folderName: String = ""
    @State var file_history: [GTLRDrive_File]
    
    var body: some View {
        VStack(spacing:100) {
            Text("Create a Folder")
                .font(.title)
                .multilineTextAlignment(.center)

            TextField("Enter Folder Name", text: $folderName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 150.0)
            
            HStack(spacing:15) {
        
                Button(action: {
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                })
                .padding()
                .foregroundColor(Color.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                
                Button(action: {
                    viewModel.createFolder(folderName, parent: file_history.last!.identifier!)
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Create Folder")
                        Spacer()
                    }
                })
                .padding()
                .foregroundColor(Color.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                
            }
            .padding(.horizontal, 150.0)
        }
    }
}


/*
struct CreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFolderView()
    }
}
*/
