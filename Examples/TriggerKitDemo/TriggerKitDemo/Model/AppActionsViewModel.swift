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

public class AppActionsViewModel: ObservableObject {
    
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
                                                           inputConnectionName: "TriggerKitDemo",
                                                           granularity: 4))
    
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
        bus.addMapping(action: .updateSlider1, cc: .init(cc: 2)) { [unowned self] payload in
            self.updateSlider(slider: &slider1, value: payload.value)
        }
        
        bus.addMapping(action: .updateSlider1, cc: .init(cc: 3)) { [unowned self] payload in
            self.updateSlider(slider: &slider2, value: payload.value)
        }
        
        bus.addMapping(action: .updateSlider3, cc: .init(cc: 4)) { [unowned self] payload in
            self.updateSlider(slider: &slider3, value: payload.value)
        }
        
        bus.addMapping(action: .updateToggle1, cc: .init(cc: 23)) { [unowned self] payload in
            self.flipToggle(toggle: &toggle1)
        }
        
        bus.addMapping(action: .updateToggle2, cc: .init(cc: 33)) { [unowned self] payload in
            self.flipToggle(toggle: &toggle2)
        }
    }
    
    func updateSlider(slider: inout Double, value: Double?) {
        guard let value else { return }
        slider = value
    }
    
    func flipToggle(toggle: inout Bool) {
        toggle.toggle()
    }
    
}
