//
//  MidiCCTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerMidiCC: Codable, Hashable {
    /// The controller that triggers, if null then any note from any controller triggers
    public var cc: Int
    
    public init(cc: Int) {
        self.cc = cc
    }
}
