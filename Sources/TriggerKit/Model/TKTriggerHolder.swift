//
//  TriggerHolder.swift
//  
//
//  Created by dave on 7/05/23.
//

import Foundation

internal class TKTriggerHolder {
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = DispatchQueue.main
        return operationQueue
    }()
    
    private var callback: TriggerCallback
    private var lastPayload: TKTriggerPayLoad?
    
    init(callback: @escaping TriggerCallback) {
        self.callback = callback
    }
    
    internal func addPayloadOperation(_ payload: TKTriggerPayLoad) {
        if let lastPayload, lastPayload == payload {
            return
        } else {
            self.operationQueue.cancelAllOperations()
            self.lastPayload = payload
            self.operationQueue.addOperation(TKOperation(callback: { isCancelled in
                self.lastPayload = nil
                guard !isCancelled else { return }
                
                self.callback(payload)
            }, payload: payload))
        }
    }
}
