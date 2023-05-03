//
//  TriggerKitDemoApp.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import SwiftUI

@main
struct TriggerKitDemoApp: App {
    @StateObject var actionsViewModel: AppActionsViewModel = AppActionsViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(actionsViewModel)
        }
    }
}
