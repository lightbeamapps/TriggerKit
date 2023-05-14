//
//  TriggerPayLoad.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

/// The callback triggered, with the payload corresponding to the event
public typealias TKPayloadCallback = (TKPayLoad) -> Void

public struct TKPayLoad: Codable, Hashable {
    /// Ranges from -1 to 1 for a gamepad axis, from 0-1.0 for CC values
    public var value: Double?
    
    // This will carry the velocity for midi notes
    public var value2: Double?
    
    // Nil for CCs, the note for notes, and directly the message if available for OSC
    public var message: String?
    
    /// - Parameters:
    ///   - value: the value of the event (ranging from 0.0-1.0) or nil
    ///   - value2: the secondary value of the event (ranging from 0.0-1.0) or nil
    ///   - message: Nil for CCs, the note for notes, and directly the message if available for OSC
    internal init(value: Double? = nil, value2: Double? = nil, message: String? = nil) {
        self.value = value
        self.value2 = value2
        self.message = message
    }
}
