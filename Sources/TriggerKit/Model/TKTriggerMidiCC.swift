//
//  MidiCCTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerMidiCC: Codable, Hashable {
    public var cc: Int
    
    public init(cc: Int) {
        self.cc = cc
    }
}
