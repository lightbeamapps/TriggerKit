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
    
    @State var currentAction: AppAction?
    
    var body: some View {
        ZStack {
            List {
                ForEach(AppAction.allCases, id: \.self) { appAction in
                    actionView(appAction: appAction)
                }
            }
            
            VStack {
                Spacer()
                self.midiReceiveView()
            }
        }
        .navigationTitle("Actions")
    }
    
    @ViewBuilder func actionView(appAction: AppAction) -> some View {
        Button {
            self.currentAction = appAction
        } label: {
            HStack {
                Text(appAction.rawValue)
                
                Spacer()
                
                if currentAction == appAction {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        }
    }
    
    @ViewBuilder func midiReceiveView() -> some View {
        HStack {
            Spacer()
            Text(actionsViewModel.eventString)
                .font(.caption)
                .padding(8)
            Spacer()
        }
        .background {
            Color.blue
        }
    }
}
