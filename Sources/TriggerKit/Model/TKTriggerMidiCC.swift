//
//  MidiCCTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

/// Represents a MIDI CC trigger with a CC value
public struct TKTriggerMidiCC: Codable, Hashable {
    /// the CC value of the midi trigger
    public var cc: Int
    
    /// - Parameter cc: the CC value of the midi trigger
    public init(cc: Int) {
        self.cc = cc
    }
}
