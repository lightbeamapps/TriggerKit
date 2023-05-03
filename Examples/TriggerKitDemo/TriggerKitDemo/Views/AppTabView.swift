//
//  AppTabView.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import SwiftUI

struct AppTabView: View {
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
