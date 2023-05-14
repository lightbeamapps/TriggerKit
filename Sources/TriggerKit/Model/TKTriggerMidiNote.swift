//
//  MidiNoteTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerMidiNote: Codable, Hashable {
    public var note: Int
    public var noteString: String
    public var noteOn: Bool

    public init(note: Int, noteString: String? = nil, noteOn: Bool = true) {
        self.note = note
        self.noteString = noteString ?? "\(note)"
        self.noteOn = noteOn
    }
}
