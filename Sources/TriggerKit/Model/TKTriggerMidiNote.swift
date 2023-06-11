//
//  MidiNoteTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation
import MIDIKit

/// Represents a MIDI note trigger
public struct TKTriggerMidiNote: Codable, Hashable {
    /// The int value of the note being triggered, e.g 62
    public var note: Int
    
    /// The string value fo the note being triggered, e.g. "D3"
    public var noteString: String
    
    /// True if the note is being held down, false if being released
    public var noteOn: Bool
    
    /// MIDI Note initializer
    /// - Parameters:
    ///   - note: The int value of the note being triggered, e.g 62
    ///   - noteString: The string value fo the note being triggered, e.g. "D3"
    ///   - noteOn: True if the note is being held down, false if being released
    public init(note: Int, noteString: String? = nil, noteOn: Bool = true) {
        self.note = note
        if let noteString {
            self.noteString = noteString
        } else if let midiNote = try? MIDINote.init(note) {
            self.noteString = midiNote.stringValue()
        } else {
            self.noteString = String(note)
        }

        self.noteOn = noteOn
    }
}
