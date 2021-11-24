//
//  ContentView.swift
//  BSP5
//
//  Created by Tim Kieffer on 11/10/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GoogleDriveViewModel

    var body: some View {
        switch viewModel.state {
           case .signedIn: Sidebar()
           case .signedOut: Sidebar()
        }
        //Sidebar()
        
    }
}






/*

struct ContentView: View {
    
    @State var selectedColor: ColorOfRectangle = .red
    @State var brightnessValue: Double = 100
    @State var opacityValue: Double = 100
    
    var body: some View {
        
        NavigationView {
            
            // Sidebar
            VStack {
                Text("Sidebar")
            }
            
            
            // Main View
            VStack {
                
                ColoredRectangleView(selectedColor: selectedColor, opacity: opacityValue/100)
                
                Picker(selection: $selectedColor, label: Text("Picker")) {
                    ForEach(ColorOfRectangle.allCases, id:\.self) {
                        Text($0.rawValue)
                    }
                }.padding(.all).pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                HStack {
                    Slider(value: $opacityValue, in: 0...100, step: 1.0)
                        .padding(.all)
                        .frame(width: 200.0)
                    Text("Opacity: " + String(Int(opacityValue)) + "%")
                        .font(.title2)
                    Spacer()
                }
                
                HStack {
                    Slider(value: $brightnessValue, in: 0...100, step: 1.0)
                        .padding(.all)
                        .frame(width: 200.0)
                    Text("Brightness: " + String(Int(brightnessValue)) + "%")
                        .font(.title2)
                    Spacer()
                }
                
                Spacer()
                
            }
        }
    }
}


enum ColorOfRectangle: String, CaseIterable {
    case red = "RED"
    case green = "GREEN"
    case blue = "BLUE"
}

struct ColoredRectangleView: View {
    var selectedColor: ColorOfRectangle
    var opacity: Double
    
    var body: some View{
        switch selectedColor {
        case .red:
            RectangleView(color: Color.red, opacity: opacity)
        case .green:
            RectangleView(color: Color.green, opacity: opacity)
        case .blue:
            RectangleView(color: Color.blue, opacity: opacity)
        }
    }
}

struct RectangleView: View {
    var color: Color
    var opacity: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .frame(width: 800.0, height: 500.0)
            .foregroundColor(color)
            .opacity(opacity)
    }
}
 */


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
