//
//  TriggerType.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation
import MIDIKit

public typealias TKTriggerEventCallback = (TKTriggerEvent?) -> (Void)

/// Wrapper for different trigger types, to transport the most recent one back for MIDI learn features
public enum TKTriggerEvent: Codable, Hashable {
    case midiNote(trigger: TKTriggerMidiNote)
    case midiCC(trigger: TKTriggerMidiCC)
    
    static func createEventFrom(midiEvent: MIDIEvent) -> TKTriggerEvent? {
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
}
