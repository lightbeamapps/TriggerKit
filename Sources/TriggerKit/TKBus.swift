//
//  File.swift
//  
//
//  Created by dave on 3/05/23.
//

import MIDIKitIO
import Foundation
import Combine

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

public class TKBus<V: TKAppActionConstraints>: ObservableObject {
    // MARK: - Data types
    public typealias TriggerCallback = (TKTriggerPayLoad) -> Void
    
    public struct MappingMidiNote: Codable, Hashable {
        var action: V
        var note: TKTriggerMidiNote
    }
    
    public struct MappingMidiCC: Codable, Hashable {
        var action: V
        var cc: TKTriggerMidiCC
    }
    
    // MARK: - Published properties
    @Published public var eventString: String = ""
    @Published public var midiEvents: [TKTriggerMidiNote] = []
    
    // MARK: - Public properties
    public var midiManager: MIDIManager
    
    // MARK: - Private properties
    private var config: TKBusConfig
    
    private var mappingsMidiNote: [MappingMidiNote: TriggerCallback] = [:]
    private var mappingsMidiCC: [MappingMidiCC: TriggerCallback] = [:]
    
    private var inputConnection: MIDIInputConnection? {
        midiManager.managedInputConnections[config.inputConnectionName]
    }
    
    // MARK: - Initialization
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
            toOutputs: [], // no need to specify if we're using .allEndpoints
            tag: "Listener",
            mode: .allEndpoints, // auto-connect to all outputs that may appear
            filter: .owned(), // don't allow self-created virtual endpoints
            receiver: .events({ [weak self] events in
                
                Task { [weak self] in
                    await self?.handleMidiEvents(events)
                }
                
                self?.eventString = events.description
            })
        )
    }
    
    private func handleMidiEvents(_ events: [MIDIEvent]) async {
        events.forEach { event in
            switch event {
            case .noteOn(let noteOn):
                let note = TKTriggerMidiNote(note: Int(noteOn.note.number))
                let payload = TKTriggerPayLoad(value: Double(noteOn.note.number), value2: noteOn.velocity.unitIntervalValue, message: "")
                
                let mappingsMatched = self.mappingsMidiNote.filter({ mapping in
                    mapping.key.note == note
                })
                                
                mappingsMatched.forEach { (key, trigger) in
                    trigger(payload)
                }
                
            default:
                break
            }
        }
    }
}

// MARK: - MidiNote Mappings
extension TKBus {
    public func addMapping(action: V, note: TKTriggerMidiNote, trigger: @escaping TriggerCallback) {
        let mapping = MappingMidiNote(action: action, note: note)
        self.mappingsMidiNote[mapping] = trigger
    }
    
    public func removeMapping(_ mapping: MappingMidiNote) {
        self.mappingsMidiNote[mapping] = nil
    }
}

// MARK: - MidiCC Mappings
extension TKBus {
    
    public func addMapping(action: V, cc: TKTriggerMidiCC, trigger: @escaping TriggerCallback) {
        let mapping = MappingMidiCC(action: action, cc: cc)
        self.mappingsMidiCC[mapping] = trigger
    }
    
    public func removeMapping(_ mapping: MappingMidiCC) {
        self.mappingsMidiCC[mapping] = nil
    }

}
