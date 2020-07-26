//
//  ContentView.swift
//  ImageGenerator
//
//  Created by Turner Eison on 7/26/20.
//  Copyright © 2020 Turner Eison. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct AddColorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: PhotoSettings
    @State var red = 0.0
    @State var green = 0.0
    @State var blue = 0.0
    
    var body: some View {
        VStack {
            Circle()
                .foregroundColor(Color.init(red: red/255.0, green: green/255.0, blue: blue/255.0))
            HStack {
                Slider(value: $red, in: 0...255)
                .accentColor(.red)
                Text("\(Int(red))")
                .foregroundColor(.red)
            }
            HStack {
                Slider(value: $green, in: 0...255)
                    .accentColor(.green)
                Text("\(Int(green))")
                    .foregroundColor(.green)
            }
            HStack {
                Slider(value: $blue, in: 0...255)
                    .accentColor(.blue)
                Text("\(Int(blue))")
                    .foregroundColor(.blue)
            }
            Button("Add color") {
                let color = RGBA32(red: UInt8(self.red), green: UInt8(self.green), blue: UInt8(self.blue), alpha: .max)
                self.settings.colors.append(color)
                self.presentationMode.wrappedValue.dismiss()
            }
        }.padding()
    }
}

struct InputView: View {
    @ObservedObject var photoSettings: PhotoSettings
    @State var customColors = true
    @State var showingAddColorView = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("Width", value: $photoSettings.width, formatter: NumberFormatter())
                        TextField("Height", value: $photoSettings.height, formatter: NumberFormatter())
                    }
                    Spacer()
                    Button(action: {
                        self.showingAddColorView = true
                    }) {
                        Image(systemName: "plus")
                        Text("Add color")
                    }
                }
                List() {
                    ForEach(photoSettings.colors) { color in
                        Color(red: Double(color.redComponent)/255.0,
                              green: Double(color.greenComponent)/255.0,
                              blue: Double(color.blueComponent)/255.0)
                    }.onDelete { (indexSet: IndexSet) in
                        self.photoSettings.colors.remove(at: indexSet.first!)
                    }
                }
                
                NavigationLink(destination: SwiftUIViewController(photoSettings: photoSettings)) {
                    if photoSettings.colors.isEmpty {
                        Text("Continue with random colors")
                    } else {
                        Text("Continue with custom colors")
                    }
                }.font(.largeTitle)
            }.sheet(isPresented: $showingAddColorView) {
                AddColorView(settings: self.photoSettings)
            }
        }
            .navigationBarTitle("Choose Colors")
            .navigationViewStyle(StackNavigationViewStyle())
            .padding()
    }
}


