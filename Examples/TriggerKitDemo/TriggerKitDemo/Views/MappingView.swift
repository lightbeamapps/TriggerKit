//
//  MappingView.swift
//  TriggerKitDemo
//
//  Created by dave on 4/05/23.
//

import SwiftUI
import TriggerKit

struct MappingView: View {
    @EnvironmentObject var bus: TKBus
    @State var currentAction: AppAction?
    
    var body: some View {
        List {
            ForEach(AppAction.allCases, id: \.self) { appAction in
                actionView(appAction: appAction)
            }
        }
    }
    
    @ViewBuilder func actionView(appAction: AppAction) -> some View {
        Button {
            self.currentAction = appAction
        } label: {
            Text(appAction.rawValue)
        }
    }
}
