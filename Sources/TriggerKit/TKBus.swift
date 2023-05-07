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
    public var granularity: Int
    
    public init(clientName: String,
                model: String,
                manufacturer: String,
                inputConnectionName: String,
                granularity: Int = 2) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.inputConnectionName = inputConnectionName
        self.granularity = granularity
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
                let payload = createPayload(value: Double(noteOn.note.number), value2: noteOn.velocity.unitIntervalValue)
                
                let mappingsMatched = self.mappingsMidiNote.filter({ mapping in
                    mapping.key.note == note
                })
                                
                mappingsMatched.forEach { (key, trigger) in
                    trigger(payload)
                }
                
            case .cc(let ccEvent):
                let cc = TKTriggerMidiCC(cc: Int(ccEvent.controller.number))
                let payload = createPayload(value: ccEvent.value.unitIntervalValue)

                let mappingsMatched = self.mappingsMidiCC.filter({ mapping in
                    mapping.key.cc == cc
                })
                                
                mappingsMatched.forEach { (key, trigger) in
                    trigger(payload)
                }

            default:
                break
            }
        }
    }
    
    private func createPayload(value: Double? = nil, value2: Double? = nil, message: String? = nil) -> TKTriggerPayLoad {
    
        
        let payload = TKTriggerPayLoad(value: roundDouble(value),
                                       value2: roundDouble(value2),
                                       message: message)
        return payload
    }
    
    private func roundDouble(_ value: Double?) -> Double? {
        guard let value else { return nil }
        
        let roundedValue = (value * 10 * Double(config.granularity)).rounded()
        
        return roundedValue / (10 * Double(config.granularity))
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
