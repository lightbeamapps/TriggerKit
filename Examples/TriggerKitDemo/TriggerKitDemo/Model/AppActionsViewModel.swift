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
    @Published var currentEvent: TKEvent?
    
    @Published var midiLearn: Bool = false
    
    // MARK: - Private properties
    public let bus = TKBus<AppAction>(config: TKBusConfig(clientName: "TriggerKitDemo",
                                                          model: "SwiftUI",
                                                          manufacturer: "lightbeamapps",
                                                          inputConnectionName: "TriggerKitDemo",
                                                          decimalPlaces: 4))
    
    init() {
        try? bus.midiStart()
        self.startup()
    }
    
    private func startup() {
        bus.setEventCallback { event in
            if let event {
                DispatchQueue.main.async { [unowned self] in
                    self.currentEvent = event
                }
            }
        }
        
        // Decode our mapped actions then loop through and all them appropriately
        // Register mappings
        bus.addMapping(.init(appAction: .updateSlider1,
                             event: .midiCC(trigger: .init(cc: 2)))) { [unowned self] payload in
            self.updateSlider(slider: &slider1, value: payload.value)
        }
        
        bus.addMapping(.init(appAction: .updateSlider2,
                             event: .midiCC(trigger: .init(cc: 3)))) { [unowned self] payload in
            self.updateSlider(slider: &slider2, value: payload.value)
        }
        
        bus.addMapping(.init(appAction: .updateSlider3,
                             event: .midiCC(trigger: .init(cc: 4)))) { [unowned self] payload in
            self.updateSlider(slider: &slider3, value: payload.value)
        }
        
        bus.addMapping(.init(appAction: .updateToggle1,
                             event: .midiCC(trigger: .init(cc: 23)))) { [unowned self] payload in
            self.flipToggle(toggle: &toggle1)
        }
        
        bus.addMapping(.init(appAction: .updateToggle2,
                             event: .midiCC(trigger: .init(cc: 33)))) { [unowned self] payload in
            self.flipToggle(toggle: &toggle2)
        }
    }
    
    private func updateSlider(slider: inout Double, value: Double?) {
        guard let value else { return }
        slider = value
    }
    
    private func flipToggle(toggle: inout Bool) {
        toggle.toggle()
    }
    
}

extension AppActionsViewModel {
    public func setMapping(_ mapping: TKMapping<AppAction>) {
        guard let currentEvent else { return }
        
        self.bus.removeMapping(mapping)
        
        var mapping = mapping
        mapping.event = currentEvent
        let callback = callbackForAction(mapping.appAction)
        self.bus.addMapping(mapping, callback: callback)
    }
}

extension AppActionsViewModel {
    private func callbackForAction(_ action: AppAction) -> TKPayloadCallback {
        switch action {
        case .updateSlider1:
            return { [unowned self] payload in
                self.updateSlider(slider: &slider1, value: payload.value)
            }
        case .updateSlider2:
            return { [unowned self] payload in
                self.updateSlider(slider: &slider2, value: payload.value)
            }
        case .updateSlider3:
            return { [unowned self] payload in
                self.updateSlider(slider: &slider3, value: payload.value)
            }
        case .updateToggle1:
            return { [unowned self] payload in
                self.flipToggle(toggle: &toggle1)
            }
        case .updateToggle2:
            return { [unowned self] payload in
                self.flipToggle(toggle: &toggle2)
            }
        }
    }
}
