//
//  ActionsView.swift
//  TriggerKitDemo
//
//  Created by dave on 4/05/23.
//

import SwiftUI
import TriggerKit

struct ActionsView: View {
    @EnvironmentObject var actionsViewModel: AppActionsViewModel
    
    var body: some View {
        ZStack {
            List {
                ForEach(actionsViewModel.bus.mappings, id: \.self) { mapping in
                    actionView(mapping: mapping)
                }
            }
            
            VStack {
                Spacer()
                self.midiReceiveView()
            }
        }
        .navigationTitle("Actions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("Midi Learn", isOn: $actionsViewModel.midiLearn)
            }
        }
    }
    
    @ViewBuilder func actionView(mapping: TKMapping<AppAction>) -> some View {
        Button {
            self.actionsViewModel.setMapping(mapping)
        } label: {
            HStack {
                Text(mapping.appAction.rawValue)
                
                Spacer()
                
                Text(mapping.event.name())
            }
        }
        .disabled(!self.actionsViewModel.midiLearn)
    }
    
    @ViewBuilder func midiReceiveView() -> some View {
        VStack {
            Text("Incoming midi events")
            HStack {
                Spacer()
                Text(actionsViewModel.currentEvent?.name() ?? "")
                    .font(.caption)
                    .padding(8)
                Spacer()
            }
        }
        .background {
            Color.blue
        }
    }
}
