//
//  WebView.swift
//  BSP5
//
//  Created by Tim Kieffer on 25/11/2021.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}


/*
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView()
    }
}
*/
