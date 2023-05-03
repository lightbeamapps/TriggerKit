//
//  AppActions.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import Foundation
import TriggerKit

public enum AppAction: String, Codable, Hashable, CaseIterable {
    case updateSlider1
    case updateSlider2
    case updateSlider3
    case updateToggle1
    case updateToggle2
}

public class AppActionsModel: ObservableObject {
        
    // The mapping of the app action to the trigger, this is stored on disk
    public struct MidiNoteMapping: Codable, Hashable {
        var action: AppAction
        var trigger: TKTriggerMidiNote
    }

    // The mapping of the app action to the trigger, this is stored on disk
    public struct MidiCCMapping: Codable, Hashable {
        var action: AppAction
        var trigger: TKTriggerMidiCC
    }
    
    // MARK: - Published properties
    @Published var slider1: Double = 0.0
    @Published var slider2: Double = 0.0
    @Published var slider3: Double = 0.0
    @Published var toggle1: Bool = false
    @Published var toggle2: Bool = false

    // MARK: - Private properties
    private let bus = TKBus(config: TKBusConfig(clientName: "TriggerKitDemo",
                                                model: "SwiftUI",
                                                manufacturer: "lightbeamapps"))
    
    init() {
        try? bus.midiStart()
    }
    
    func startup() {
        // Decode our mapped actions
        let midiCCMapping1 = MidiCCMapping(action: .updateSlider1, trigger: .init(cc: "71"))
        let midiCCMapping2 = MidiCCMapping(action: .updateSlider2, trigger: .init(cc: "55"))
        let midiCCMapping3 = MidiCCMapping(action: .updateSlider3, trigger: .init(cc: "66"))
        
        let midiCCMappings = [midiCCMapping1, midiCCMapping2, midiCCMapping3]
        
        var activeMappings: [UUID: MidiCCMapping] = [:]
        
        // Register mappings
        midiCCMappings.forEach { mapping in
            let id = bus.addTrigger(mapping.trigger) { [unowned self] payload in
                handleAction(mapping.action, payload: payload)
            }
            
            activeMappings[id] = mapping
        }
    }
    
    func handleAction(_ action: AppAction, payload: TKTriggerPayLoad) {
        switch action {
        case .updateSlider1:
            if let value = payload.value {
                slider1 = value
            }
        case .updateSlider2:
            if let value = payload.value {
                slider2 = value
            }
        case .updateSlider3:
            if let value = payload.value {
                slider3 = value
            }
        case .updateToggle1:
            toggle1.toggle()
        case .updateToggle2:
            toggle2.toggle()
        }
    }
    
}
