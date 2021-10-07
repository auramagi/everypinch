//
//  ContentView.swift
//  EveryPinchApp
//
//  Created by Mikhail Apurin on 2021/10/07.
//

import SwiftUI
import PinchCore

struct ContentView: View {
    var body: some View {
        Button("Test", action: testMultitouch)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
