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
            NavigationStack {
                DemoView()
            }
            .tabItem {
                Label("Demo", systemImage: "play.circle")
            }
            
            NavigationStack {
                ActionsView()
            }
            .tabItem {
                Label("Mapping", systemImage: "switch.2")
            }
            
            NavigationStack {
                TKBluetoothMIDIView()
            }
            .tabItem {
                Label("Connect", image: "logo.bluetooth")
            }
        }
    }
}
