//
//  RenameFileView.swift
//  BSP5
//
//  Created by Tim Kieffer on 02/12/2021.
//

import SwiftUI
import GoogleAPIClientForREST

struct RenameFileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: GoogleDriveViewModel

    var file: GTLRDrive_File
    @State var newFileName: String = ""
    
    var body: some View {
        VStack(spacing:100) {
            Text("Rename File")
                .font(.title)
                .multilineTextAlignment(.center)

            TextField(file.name!, text: $newFileName)
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
                    viewModel.updateFileName(file: file, newName: newFileName) { error in
                        guard let error = error else {
                            return
                        }
                        print("Error when updating file name: \(error)")
                    }
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Rename")
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
        .onAppear {
            newFileName = file.name!
        }
    }
}

/*
struct RenameFileView_Previews: PreviewProvider {
    static var previews: some View {
        RenameFileView()
    }
}
*/