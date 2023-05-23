//
//  TKBus.swift
//  
//
//  Created by dave on 3/05/23.
//

import MIDIKitIO
import Foundation
import Combine

/// Configuration for the TriggerKit Bus
///
/// This is given to TKBus when it is initialized, containing all configurable values
public struct TKBusConfig {
    internal var clientName: String
    internal var model: String
    internal var manufacturer: String
    internal var inputConnectionName: String = "TriggerKit"
    internal var decimalPlaces: Int

    /// Configuration for the TriggerKit Bus
    /// - Parameters:
    ///   - clientName: Name identifying this instance, used via MIDIKit as a Core MIDI client ID
    ///   - model: The name of your client application, used by MIDIKit
    ///   - manufacturer: The name of your company used by MIDIKit
    ///     created by the manager.
    ///   - decimalPlaces: the number of decimal places MIDI CC values are rounded to
    public init(clientName: String,
                model: String,
                manufacturer: String,
                decimalPlaces: Int = 2,
                throttleRate: Double = 1 / 120) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.decimalPlaces = decimalPlaces
    }
}

/// Represents the a unique mapping of an app action to an event
///
/// Mappings are registered with TKBus in order to associate events, and app actions, to blocks of code to be triggered.
public struct TKMapping<V>: Hashable, Codable where V: TKAppActionConstraints  {
    /// The unique id of the mapping
    public var id: UUID    
    /// Your application's enum representing an action that the app has
    public var appAction: V
    /// The TriggerKit event that triggers the appAction and associated block of code
    public var event: TKEvent?
    
    /// Represents the a unique mapping of an app action to an event
    /// - Parameters:
    ///   - id: the unique ID of the mapping. This can be supplied by the client app if decoding existing mappings, or created by the initializer itself.
    ///   - appAction: Your application's enum representing an action that the app has
    ///   - event: The TriggerKit event that triggers the appAction and associated block of code
    public init(id: UUID = UUID(), appAction: V, event: TKEvent?) {
        self.id = id
        self.appAction = appAction
        self.event = event
    }
}

/// Core TriggerKit Bus object
///
/// This is the core TriggerKit bus, that your application will use to hold mappings in memory and trigger them according to the events supplied.
public class TKBus<V>: ObservableObject where V: TKAppActionConstraints  {
    // MARK: - Published public properties
    
    /// The latest event received
    @Published public var event: TKEvent?
        
    /// The current mappings associated with events
    @Published public var mappings: [TKMapping<V>] = []

    // MARK: - Published private properties
    
    /// The latest MIDI Note event
    @Published private var latestNoteEvent: MIDIEvent?
    
    /// The latest MIDI CC event
    @Published private var latestCCEvent: MIDIEvent?
    
    // MARK: - Public properties
    public var midiManager: MIDIManager
    
    // MARK: - Private properties
    
    /// The configuration supplied by the application
    private var config: TKBusConfig
    
    /// A look-up for the callbacks to call when events are triggered, linked by the UUID
    private var callbacks: [UUID: TKPayloadCallback] = [:]
        
    /// A single callback for each event, to enable event learning in the application
    private var eventCallback: TKEventCallback?
    
    /// The store for TriggerKit's Combine bindings
    private var cancellables = Set<AnyCancellable>()
    
    /// A value for the input connection, used with MIDIKit
    private var inputConnection: MIDIInputConnection? {
        midiManager.managedInputConnections[config.inputConnectionName]
    }
    
    // MARK: - Initialization
    
    /// Initialize the TKBus object
    /// - Parameter config: A struct containing all configurable values
    public init(config: TKBusConfig) {
        self.config = config
        
        midiManager = MIDIManager(
            clientName: config.clientName,
            model: config.model,
            manufacturer: config.manufacturer
        )
        
        self.setBindings()
    }
        
    /// Bindings triggered when events are received from MIDI
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
    
    /// Called when you are ready for the TKBus to set up connections and listen for events
    public func start() throws {
        try midiManager.start()
        
        try midiManager.addInputConnection(
            toOutputs: [], // no need to specify if we're using .allEndpoints
            tag: config.inputConnectionName,
            mode: .allEndpoints, // auto-connect to all outputs that may appear
            filter: .owned(), // don't allow self-created virtual endpoints
            receiver: .events({ [weak self] events in
                self?.processMidiEvents(events)
            })
        )
    }
    
    /// Private handler method for event arrays received from the MIDI manager
    private func processMidiEvents(_ events: [MIDIEvent]) {
        events.forEach({ event in
            handleMidiEvent(event)
        })
    }
    
    /// Handles a single event
    /// - Parameter midiEvent: handles each single midi event, and ensure that callbacks are called on the main thread
    internal func handleMidiEvent(_ midiEvent: MIDIEvent) {
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
    
    /// Creates a PayLoad from a midi event
    ///
    /// - Parameter event: the midi event to create a payload from
    /// - Returns: a standard TK payload struct
    internal func createPayload(_ event: MIDIEvent) -> TKPayLoad? {
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
    
    /// Add Mapping
    ///
    /// This updates an existing mapping if the UUID matches one held, OR adds a new one at the end of the mappings array if not. Executes changes to the mappings property on the main thread.
    /// - Parameters:
    ///   - newMapping: the mapping to be created
    ///   - callback: the callback to call when the mapping's event is received.
    public func addMapping(_ newMapping: TKMapping<V>, callback: TKPayloadCallback?) {
        DispatchQueue.main.async { [weak self] in
            if let index = self?.mappings.firstIndex(where: { mapping in
                mapping.id == newMapping.id
            }) {
                self?.mappings[index] = newMapping
            } else {
                self?.mappings.append(newMapping)
            }
            
            self?.callbacks[newMapping.id] = nil
            
            self?.callbacks[newMapping.id] = callback
        }
    }
    
    public func removeMapping(_ mapping: TKMapping<V>) {
        DispatchQueue.main.async { [weak self] in
            self?.mappings.removeAll { item in
                item.id == mapping.id
            }
            
            self?.callbacks[mapping.id] = nil
        }
    }
    
}

// MARK: - Event Mappings
extension TKBus {
    /// Updates the event callback that is executed when a new event is received. This supports event learning in the application.
    /// - Parameter callback: The callback to be called
    public func setEventCallback(_ callback: TKEventCallback?) {
        eventCallback = callback
    }
    
    /// Removes the current event bacllback that is executed when a new event is received.
    public func removeEventCallback() {
        eventCallback = nil
    }
}

// MARK: - Convenience functions
extension TKBus {
    
    /// Creates a payload based on a the values provided. Used internally to have one spot where this happens
    ///
    /// - Parameters:
    ///   - value: the main value of the payload
    ///   - value2: the secondary value of the paylaod
    ///   - message: some events pass messages back. This is future proofing for support for things like OSC where events can have some extra meta data supplied.
    /// - Returns: a TK Payload struct
    internal func createPayload(value: Double, value2: Double? = nil, message: String? = nil) -> TKPayLoad {
        let payload = TKPayLoad(value: roundDouble(value) ?? 0,
                                       value2: roundDouble(value2),
                                       message: message)
        return payload
    }
    
    internal func roundDouble(_ value: Double?) -> Double? {
        guard let value else { return nil }
        
        let multiplier = pow(Double(10), Double(config.decimalPlaces))
        
        let roundedValue = Double(round(multiplier  * value))
        return roundedValue / multiplier
    }
    
    internal func logEvent(_ event: TKEvent?) {
        DispatchQueue.main.async { [weak self] in
            self?.eventCallback?(event)
        }
    }
    
}
