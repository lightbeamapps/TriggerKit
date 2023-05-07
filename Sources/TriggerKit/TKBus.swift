//
//  TKBus.swift
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
    public var throttleRate: Double
    
    public init(clientName: String,
                model: String,
                manufacturer: String,
                inputConnectionName: String,
                granularity: Int = 2,
                throttleRate: Double = 1 / 120) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.inputConnectionName = inputConnectionName
        self.granularity = granularity
        self.throttleRate = throttleRate
    }
}

public class TKBus<V: TKAppActionConstraints>: ObservableObject {
    // MARK: - Data types
    
    public struct MappingMidiNote: Codable, Hashable {
        var action: V
        var note: TKTriggerMidiNote
    }
    
    public struct MappingMidiCC: Codable, Hashable {
        var action: V
        var cc: TKTriggerMidiCC
    }
    
    // MARK: - Published public properties
    @Published public var eventString: String = ""
    @Published public var midiEvents: [TKTriggerMidiNote] = []
    
    // MARK: - Published private properties
    @Published private var latestNoteEvent: MIDIEvent?
    @Published private var latestCCEvent: MIDIEvent?
    
    // MARK: - Public properties
    public var midiManager: MIDIManager
    
    // MARK: - Private properties
    private var config: TKBusConfig
    
    private var mappingsMidiNote: [MappingMidiNote: TKTriggerHolder] = [:]
    private var mappingsMidiCC: [MappingMidiCC: TKTriggerHolder] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        self.setBindings()
    }
    
    private func setBindings() {
        self.$latestCCEvent
            .sink { event in
                guard let event else { return }
                self.handleMidiEvent(event)
            }
            .store(in: &cancellables)
    }
    
    public func midiStart() throws {
        try midiManager.start()
        
        try midiManager.addInputConnection(
            toOutputs: [], // no need to specify if we're using .allEndpoints
            tag: "Listener",
            mode: .allEndpoints, // auto-connect to all outputs that may appear
            filter: .owned(), // don't allow self-created virtual endpoints
            receiver: .events({ [weak self] events in
                self?.processMidiEvents(events)
            })
        )
    }
    
    private func processMidiEvents(_ events: [MIDIEvent]) {
        events.forEach({ event in
            switch event {
            case .noteOn, .noteOff:
                self.latestNoteEvent = event
            case .cc:
                self.latestCCEvent = event
            default:
                break;
            }
        })
    }
    
    private func handleMidiEvent(_ event: MIDIEvent) {
        self.eventString = event.description
        
        switch event {
        case .noteOn(let noteOn):
            let note = TKTriggerMidiNote(note: Int(noteOn.note.number))
            let payload = createPayload(value: Double(noteOn.note.number), value2: noteOn.velocity.unitIntervalValue)
            
            let mappingsMatched = self.mappingsMidiNote.filter({ mapping in
                mapping.key.note == note
            })
            
            mappingsMatched.forEach { (key, holder) in
                holder.addPayloadOperation(payload)
            }
            
        case .cc(let ccEvent):
            let cc = TKTriggerMidiCC(cc: Int(ccEvent.controller.number))
            let payload = createPayload(value: ccEvent.value.unitIntervalValue)
            
            let mappingsMatched = self.mappingsMidiCC.filter({ mapping in
                mapping.key.cc == cc
            })
            
            mappingsMatched.forEach { (key, holder) in
                holder.addPayloadOperation(payload)
            }
            
        default:
            break
        }
    }
    
}

// MARK: - MidiNote Mappings
extension TKBus {
    public func addMapping(action: V, note: TKTriggerMidiNote, trigger: @escaping TriggerCallback) {
        let mapping = MappingMidiNote(action: action, note: note)
        let holder = TKTriggerHolder(callback: trigger)
        self.mappingsMidiNote[mapping] = holder
    }
    
    public func removeMapping(_ mapping: MappingMidiNote) {
        self.mappingsMidiNote[mapping] = nil
    }
}

// MARK: - MidiCC Mappings
extension TKBus {
    
    public func addMapping(action: V, cc: TKTriggerMidiCC, trigger: @escaping TriggerCallback) {
        let mapping = MappingMidiCC(action: action, cc: cc)
        let holder = TKTriggerHolder(callback: trigger)
        self.mappingsMidiCC[mapping] = holder
    }
    
    public func removeMapping(_ mapping: MappingMidiCC) {
        self.mappingsMidiCC[mapping] = nil
    }
    
}

// MARK: - Convenience functions
extension TKBus {
    
    internal func createPayload(value: Double? = nil, value2: Double? = nil, message: String? = nil) -> TKTriggerPayLoad {
        let payload = TKTriggerPayLoad(value: roundDouble(value),
                                       value2: roundDouble(value2),
                                       message: message)
        return payload
    }
    
    internal func roundDouble(_ value: Double?) -> Double? {
        guard let value else { return nil }
        
        let roundedValue = (value * 10 * Double(config.granularity)).rounded()
        
        return roundedValue / (10 * Double(config.granularity))
    }
}
