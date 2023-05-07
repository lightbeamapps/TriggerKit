//
//  AppTabView.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import SwiftUI
import TriggerKit

struct AppTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                DemoView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Demo", systemImage: "play.circle")
            }
            
            NavigationView {
                ActionsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Mapping", systemImage: "switch.2")
            }
            
            NavigationView {
                TKBluetoothMIDIView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Mapping", image: "logo.bluetooth")
            }
        }
    }
}
