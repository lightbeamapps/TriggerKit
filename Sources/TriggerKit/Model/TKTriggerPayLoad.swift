//
//  TriggerPayLoad.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

public struct TKTriggerPayLoad: Codable, Hashable {
    /// Ranges from -1 to 1 for a gamepad axis, from 0-1.0 for CC values
    public var value: Double?
    
    // Nil for CCs, the note for notes, and directly the message if available for OSC
    public var message: String?
    
    internal init(value: Double? = nil, message: String? = nil) {
        self.value = value
        self.message = message
    }
}
