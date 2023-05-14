//
//  TestConfig.swift
//  
//
//  Created by dave on 14/05/23.
//

import XCTest

enum TestConfig {
    static var defaultMaxWaitTime: TimeInterval = 1.0
}

extension XCTestCase {
    func defaultWaitForExpectations() {
        self.waitForExpectations(timeout: TestConfig.defaultMaxWaitTime)
    }
}

extension XCTestCase {
    func waitForMainThread() {
        let expectation = self.expectation(description: "TriggerKit - waiting for main thread")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: TestConfig.defaultMaxWaitTime)
    }
}
