//
//  AppActions.swift
//  TriggerKitDemo
//
//  Created by dave on 3/05/23.
//

import Foundation
import TriggerKit

public enum AppAction: String, Codable, Hashable, CaseIterable, Equatable {
    case updateSlider1
    case updateSlider2
    case updateSlider3
    case updateToggle1
    case updateToggle2
}

@MainActor public class AppActionsViewModel: ObservableObject {
    
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
    @Published var eventString: String = ""
    
    @Published var midiLearn: Bool = false
    
    // MARK: - Private properties
    private let bus = TKBus<AppAction>(config: TKBusConfig(clientName: "TriggerKitDemo",
                                                model: "SwiftUI",
                                                manufacturer: "lightbeamapps",
                                                inputConnectionName: "TriggerKitDemo"))
    
    init() {
        try? bus.midiStart()
        self.setBindings()
        self.startup()
    }
    
    func setBindings() {
        Task {
            for await value in bus.$eventString.values {
                await updateEventString(value)
            }
        }
    }
    
    @MainActor func updateEventString(_ value: String) async {
        self.eventString = value
    }
    
    func startup() {
        // Decode our mapped actions then loop through and all them appropriately
        
        // Register mappings
        bus.addMapping(action: .updateSlider1, cc: .init(cc: "71")) { [unowned self] payload in
            Task { self.updateSlider(slider: &slider1, value: payload.value) }
        }
        
        bus.addMapping(action: .updateSlider1, cc: .init(cc: "55")) { [unowned self] payload in
            Task { self.updateSlider(slider: &slider2, value: payload.value) }
        }
                
        bus.addMapping(action: .updateSlider1, cc: .init(cc: "66")) { [unowned self] payload in
            Task { self.updateSlider(slider: &slider3, value: payload.value) }
        }
        
        bus.addMapping(action: .updateSlider1, note: .init(note: 62)) { [unowned self] payload in
            Task {
                self.flipToggle(toggle: &toggle1)
            }
        }
    }
        
    @MainActor func updateSlider(slider: inout Double, value: Double?) {
        guard let value else { return }
        slider = value
    }
            
    @MainActor func flipToggle(toggle: inout Bool) {
        toggle.toggle()
    }
    
}
