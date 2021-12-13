//
//  GoogleDriveShowImage.swift
//  BSP5
//
//  Created by Tim Kieffer on 19/11/2021.
//

import SwiftUI
import GoogleAPIClientForREST

struct PreviewView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: GoogleDriveViewModel
    
    @State var file: GTLRDrive_File
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            WebView(url: URL(string: file.webViewLink!)!)
            
            Button(action: {
                dismiss()
            }, label: {
                Text("Close Preview")
            })
            .padding()
            .foregroundColor(Color.white)
            .background(Color.accentColor)
            .cornerRadius(8)
            .padding()
        }
    }
}


/*
struct GoogleDriveShowImage_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
}
*/
