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
            
            /*
            
            Text("Preview ---- \(file.webViewLink!)")
            
            Link("Preview in Safari", destination: URL(string: file.webViewLink!)!)
            
            //AsyncImage(url: URL(string: imageLink))
            
            
            
            let url = self.getDocumentsDirectory().appendingPathComponent("test_image.jpg")
            
            Button("Download File") {
                viewModel.download(file.identifier!) { (data, error) in
                    guard let data = data else {
                        return
                    }
                 
                    do {
                        try data.write(to: url)
                        print("------------------ URL:", url)
                        let input = try String(contentsOf: url)
                        print(input)
                    } catch {
                        print("Write Error: \(error.localizedDescription)")
                    }
                
                }
            }
            */
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}


/*
struct GoogleDriveShowImage_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
}
*/
