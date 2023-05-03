//
//  TKController.swift
//  
//
//  Created by dave on 3/05/23.
//

import Foundation

/// A holder for the type of controller
public struct TKController: Codable, Hashable {
    public var identifier: String
    public var triggerType: TKTriggerType
}
