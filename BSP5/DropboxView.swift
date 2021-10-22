//
//  DropboxView.swift
//  BSP5
//
//  Created by Tim Kieffer on 18/10/2021.
//

import SwiftUI

struct DropboxView: View {
    var body: some View {
        VStack {
            List(1..<11) { item in
                Label("Test Folder \(item)", systemImage: "folder")
            }
        }
        .navigationTitle("Dropbox")
    }
}

struct DropboxView_Previews: PreviewProvider {
    static var previews: some View {
        DropboxView()
    }
}
