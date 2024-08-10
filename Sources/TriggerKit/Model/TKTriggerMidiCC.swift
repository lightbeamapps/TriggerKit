//
//  MidiCCTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation
import MIDIKit

/// Represents a MIDI CC trigger with a CC value
public struct TKTriggerMidiCC: Codable, Hashable {
    /// the CC value of the midi trigger
    public var cc: Int
    
    public var channel: UInt4?
    
    /// - Parameter cc: the CC value of the midi trigger
    public init(
        cc: Int,
        channel: UInt4? = nil
    ) {
        self.cc = cc
        self.channel = channel
    }
}
