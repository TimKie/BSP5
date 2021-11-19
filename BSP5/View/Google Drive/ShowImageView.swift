//
//  GoogleDriveShowImage.swift
//  BSP5
//
//  Created by Tim Kieffer on 19/11/2021.
//

import SwiftUI

struct ShowImageView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var imageLink: String = ""
    
    var body: some View {
        VStack {
        
            Button("Close") {
                dismiss()
            }
        
            AsyncImage(url: URL(string: imageLink))
            
        }
    }
}

struct GoogleDriveShowImage_Previews: PreviewProvider {
    static var previews: some View {
        ShowImageView()
    }
}
