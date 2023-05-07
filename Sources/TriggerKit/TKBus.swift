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
    public typealias TriggerCallback = (TKTriggerPayLoad) -> Void
    
    internal class TKOperation: Operation {
        
        private var callback: (Bool) -> Void
        private var payload: TKTriggerPayLoad
        
        init(callback: @escaping (Bool) -> Void,
             payload: TKTriggerPayLoad) {
            self.callback = callback
            self.payload = payload
            
            super.init()
        }
        
        override func main() {
            callback(isCancelled)
        }
    }
    
    internal class TriggerHolder {
        private var operationQueue: OperationQueue = {
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInteractive
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.underlyingQueue = DispatchQueue.main
            return operationQueue
        }()
        
        private var callback: TriggerCallback
        private var lastPayload: TKTriggerPayLoad?
        
        init(callback: @escaping TriggerCallback) {
            self.callback = callback
        }
        
        internal func addPayloadOperation(_ payload: TKTriggerPayLoad) {
            if let lastPayload, lastPayload == payload {
                return
            } else {
                self.operationQueue.cancelAllOperations()
                self.lastPayload = payload
                self.operationQueue.addOperation(TKOperation(callback: { isCancelled in
                    self.lastPayload = nil
                    guard !isCancelled else {
                        print("cancelled")
                        return }
                    
                    self.callback(payload)
                }, payload: payload))
            }
        }
        
    }
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
    
    private var mappingsMidiNote: [MappingMidiNote: TriggerHolder] = [:]
    private var mappingsMidiCC: [MappingMidiCC: TriggerHolder] = [:]
    
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
        let holder = TriggerHolder(callback: trigger)
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
        let holder = TriggerHolder(callback: trigger)
        self.mappingsMidiCC[mapping] = holder
    }
    
    public func removeMapping(_ mapping: MappingMidiCC) {
        self.mappingsMidiCC[mapping] = nil
    }
    
}
