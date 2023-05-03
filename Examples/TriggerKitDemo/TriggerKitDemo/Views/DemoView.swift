//
//  DemoView.swift
//  TriggerKitDemo
//
//  Created by dave on 4/05/23.
//

import SwiftUI

struct DemoView: View {
    @EnvironmentObject var actionsViewModel: AppActionsViewModel
    
    var body: some View {
        VStack {
            Slider(value: $actionsViewModel.slider1) {
                Text("1")
            }
            Slider(value: $actionsViewModel.slider2) {
                Text("2")
            }
            
            Slider(value: $actionsViewModel.slider3) {
                Text("3")
            }
            
            HStack {
                Toggle("1", isOn: $actionsViewModel.toggle1)
                Spacer()
                    .padding()
                Toggle("2", isOn: $actionsViewModel.toggle2)
            }

        }
        .navigationTitle("Demo")
        .padding()
    }
}
