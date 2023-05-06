//
//  MidiNoteTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerMidiNote: Codable, Hashable {
    /// The controller that triggers, if null then any note from any controller triggers
    public var controller: TKController?
    public var note: Int
    public var noteOn: Bool

    public init(controller: TKController? = nil, note: Int, noteOn: Bool = true) {
        self.controller = controller
        self.note = note
        self.noteOn = noteOn
    }
}
