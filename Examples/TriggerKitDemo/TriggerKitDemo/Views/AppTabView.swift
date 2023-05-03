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
            NavigationView {
                DemoView()
            }
            .tabItem {
                Label("Demo", systemImage: "play.circle")
            }
            
            NavigationView {
                ActionsView()
            }
            .tabItem {
                Label("Mapping", systemImage: "switch.2")
            }
        }
    }
}
