//
//  ContentView.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            VStack {
                Text("stuff to control here")
            }
            .tabItem {
                Label("Demo", systemImage: "play.circle")
            }

            VStack {
                Text("Configure here")
            }
            .tabItem {
                Label("Mapping", systemImage: "switch.2")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
