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
    public var decimalPlaces: Int
    public var throttleRate: Double
    
    public init(clientName: String,
                model: String,
                manufacturer: String,
                inputConnectionName: String,
                decimalPlaces: Int = 2,
                throttleRate: Double = 1 / 120) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.inputConnectionName = inputConnectionName
        self.decimalPlaces = decimalPlaces
        self.throttleRate = throttleRate
    }
}

public struct TKMapping<V> where V: TKAppActionConstraints  {
    public var id: UUID
    public var appAction: V
    public var event: TKEvent
    
    public init(id: UUID = UUID(), appAction: V, event: TKEvent) {
        self.id = id
        self.appAction = appAction
        self.event = event
    }
}

public class TKBus<V>: ObservableObject where V: TKAppActionConstraints  {
    // MARK: - Published public properties
    @Published public var event: TKEvent?
    
    // MARK: - Published private properties
    @Published private var latestNoteEvent: MIDIEvent?
    @Published private var latestCCEvent: MIDIEvent?
    
    // MARK: - Public properties
    public var midiManager: MIDIManager
    
    // MARK: - Private properties
    private var config: TKBusConfig
    
    private var mappings: [TKMapping<V>] = []
    private var callbacks: [UUID: TKPayloadCallback] = [:]
        
    private var eventCallback: TKEventCallback?
    
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
        
        self.$latestNoteEvent
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
            handleMidiEvent(event)
        })
    }
    
    private func handleMidiEvent(_ midiEvent: MIDIEvent) {
        guard
            let event = TKEvent.createEventFrom(midiEvent: midiEvent),
            let payload = createPayload(midiEvent)
        else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.eventCallback?(event)
        }
                
        let mappings = self.mappings.filter({ $0.event == event })
        
        mappings.forEach { mapping in
            guard let callback = self.callbacks[mapping.id] else { return }
            
            DispatchQueue.main.async {
                callback(payload)
            }
        }
    }
    
    private func createPayload(_ event: MIDIEvent) -> TKPayLoad? {
        switch event {
        case .noteOn(let noteOn):
            return createPayload(value: Double(noteOn.note.number), value2: noteOn.velocity.unitIntervalValue)
        case .cc(let ccEvent):
            return createPayload(value: ccEvent.value.unitIntervalValue)
        default:
            break
        }
        
        return nil
    }
    
}

// MARK: - TKEvent Mappings
extension TKBus {
    
    public func addMapping(_ mapping: TKMapping<V>, callback: @escaping TKPayloadCallback) {
        self.removeMapping(mapping) // Replace the existing mapping
        self.mappings.append(mapping)
        self.callbacks[mapping.id] = callback
    }
    
    public func removeMapping(_ mapping: TKMapping<V>) {
        self.mappings.removeAll { item in
            item.id == mapping.id
        }
                
        self.callbacks[mapping.id] = nil
    }
    
}

// MARK: - Event Mappings
extension TKBus {
    public func setEventCallback(_ callback: TKEventCallback?) {
        eventCallback = callback
    }
    
    public func removeEventCallback() {
        eventCallback = nil
    }
}

// MARK: - Convenience functions
extension TKBus {
    
    internal func createPayload(value: Double? = nil, value2: Double? = nil, message: String? = nil) -> TKPayLoad {
        let payload = TKPayLoad(value: roundDouble(value),
                                       value2: roundDouble(value2),
                                       message: message)
        return payload
    }
    
    internal func roundDouble(_ value: Double?) -> Double? {
        guard let value else { return nil }
        
        let roundedValue = (value * 10 * Double(config.decimalPlaces)).rounded()
        
        return roundedValue / (10 * Double(config.decimalPlaces))
    }
    
    internal func logEvent(_ event: TKEvent?) {
        DispatchQueue.main.async { [weak self] in
            self?.eventCallback?(event)
        }
    }
    
}
