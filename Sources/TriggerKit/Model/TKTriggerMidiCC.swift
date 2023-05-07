//
//  MidiCCTrigger.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerMidiCC: Codable, Hashable {
    /// The controller that triggers, if null then any note from any controller triggers
    public var controller: TKController?
    public var cc: Int
    
    public init(controller: TKController? = nil, cc: Int) {
        self.controller = controller
        self.cc = cc
    }
}
