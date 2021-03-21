//
//  ContentView.swift
//  WeLoopSwiftUI
//
//  Created by Henry Huck on 06/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import WeLoop

struct ContentView: View {
    var body: some View {
        Button("manual") {
            WeLoop.invoke()
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
