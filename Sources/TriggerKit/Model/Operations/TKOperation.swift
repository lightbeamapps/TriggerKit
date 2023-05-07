//
//  TriggerHolder.swift
//  
//
//  Created by dave on 7/05/23.
//

import Foundation

internal class TKOperation: Operation {
    
    private var callback: (Bool) -> Void
    private var payload: TKTriggerPayLoad
    
    init(callback: @escaping (Bool) -> Void,
         payload: TKTriggerPayLoad) {
        self.callback = callback
        self.payload = payload
        
        super.init()
    }
    
    override func main() {
        callback(isCancelled)
    }
}
