//
//  TriggerType.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation
import MIDIKit

/// The callback executed when an event is received by the TKBus object. Typically used for event learn features in the application
public typealias TKEventCallback = (TKEvent?) -> (Void)

/// Wrapper for different trigger types, to transport the most recent one back for MIDI learn features
public enum TKEvent: Codable, Hashable {
    case midiNote(trigger: TKTriggerMidiNote)
    case midiCC(trigger: TKTriggerMidiCC)
    
    internal static func createEventFrom(midiEvent: MIDIEvent) -> TKEvent? {
        switch midiEvent {
        case .noteOn(let noteOn):
            let trigger = TKTriggerMidiNote(note: Int(noteOn.note.number), noteString: noteOn.note.stringValue())
            return .midiNote(trigger: trigger)
        case .cc(let ccEvent):
            let trigger = TKTriggerMidiCC(cc: Int(ccEvent.controller.number))
            return .midiCC(trigger: trigger)
        default:
            return nil
        }
    }
    
    public func name() -> String {
        switch self {
        case .midiCC(let trigger):
            return "CC: \(trigger.cc)"
        case .midiNote(let trigger):
            return "Note: \(trigger.note), \(trigger.noteString)"
        }
    }
}
