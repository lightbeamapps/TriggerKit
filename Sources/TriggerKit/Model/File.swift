//
//  Logger.swift
//  
//
//  Created by dave on 7/05/23.
//

import Foundation

enum Logger {
    
    internal func log(_ value: String) {
        #if DEBUG
        print(value)
        #endif
    }
}
