//
//  File.swift
//  
//
//  Created by dave on 3/05/23.
//

import MIDIKitIO
import Foundation
import Combine

public typealias TriggerCallback = (TKTriggerPayLoad) -> Void

public struct TKBusConfig {
    public var clientName: String
    public var model: String
    public var manufacturer: String
    public var inputConnectionName: String
    
    public init(clientName: String, model: String, manufacturer: String, inputConnectionName: String) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.inputConnectionName = inputConnectionName
    }
}

internal struct TKMappingMidiNote {
    var trigger: TKTriggerMidiNote
    var action: TriggerCallback
}

internal struct TKMappingMidiCC {
    var trigger: TKTriggerMidiCC
    var action: TriggerCallback
}

public class TKBus: ObservableObject {
    @Published public var eventString: String = ""
    
    public var midiManager: MIDIManager
    
    private var triggersMidiNote: [UUID: TKMappingMidiNote] = [:]
    private var triggersMidiCC: [UUID: TKMappingMidiCC] = [:]
    
    private var config: TKBusConfig
    
    private var inputConnection: MIDIInputConnection? {
        midiManager.managedInputConnections[config.inputConnectionName]
    }
    
    public init(config: TKBusConfig) {
        self.config = config
        
        midiManager = MIDIManager(
            clientName: config.clientName,
            model: config.model,
            manufacturer: config.manufacturer
        )
    }
    
    public func midiStart() throws {
        try midiManager.start()
        
        try midiManager.addInputConnection(
            toOutputs: [.name("IDAM MIDI Host")],
            tag: config.inputConnectionName,
            receiver: MIDIReceiver.eventsLogging(filterActiveSensingAndClock: false, { eventString in
                self.eventString = eventString
            })
        )
    }
    
    public func addController(_ controller: TKController) {
        // TODO:-
    }
    
    public func removeController(_ controller: TKController) {
        // TODO:-
    }
    
    public func addTrigger(_ trigger: TKTriggerMidiNote, action: @escaping TriggerCallback) -> UUID {
        let mapping = TKMappingMidiNote(trigger: trigger, action: action)
        let uuid = UUID()
        
        triggersMidiNote[uuid] = mapping
        return uuid
    }
    
    public func addTrigger(_ trigger: TKTriggerMidiCC, action: @escaping TriggerCallback) -> UUID {
        let mapping = TKMappingMidiCC(trigger: trigger, action: action)
        let uuid = UUID()
        
        triggersMidiCC[uuid] = mapping
        return uuid
    }
    
    public func removeTrigger(uuid: UUID, type: TKTriggerType) {
        switch type {
        case .midiNote:
            self.triggersMidiNote[uuid] = nil
        case .midiCC:
            self.triggersMidiCC[uuid] = nil
        }
    }

}
