//
//  ConfigTests.swift
//  
//
//  Created by dave on 14/05/23.
//

import XCTest
@testable import TriggerKit

final class ConfigTests: XCTestCase {
    
    enum TestAction: TKAppActionConstraints {
        case testAction1
        case testAction2
        case testAction3
    }
     
    func testStandardRoundingUp() {
        // Given
        let config = TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps")
        let bus = TKBus<TestAction>(config: config)
        let mapping = TKMapping(appAction: TestAction.testAction1, event: TKEvent.midiCC(trigger: .init(cc: 1)))
        
        let expectation = expectation(description: "testNonStandardRoundingUp")
        
        bus.addMapping(mapping) { payload in
            if payload.value == 0.12 {
                expectation.fulfill()
            }
        }
        
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value:.unitInterval(0.115), channel: 0))
        
        // Then
        defaultWaitForExpectations()
    }
    
    func testNonStandardRoundingUp() {
        // Given
        let config = TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps", decimalPlaces: 3)
        let bus = TKBus<TestAction>(config: config)
        let mapping = TKMapping(appAction: TestAction.testAction1, event: TKEvent.midiCC(trigger: .init(cc: 1)))
        
        let expectation = expectation(description: "testNonStandardRoundingUp")
        
        bus.addMapping(mapping) { payload in
            if payload.value == 0.112 {
                expectation.fulfill()
            }
        }
        
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value:.unitInterval(0.1115), channel: 0))
        
        // Then
        defaultWaitForExpectations()
    }

    func testStandardRoundingDown() {
        // Given
        let config = TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps")
        let bus = TKBus<TestAction>(config: config)
        let mapping = TKMapping(appAction: TestAction.testAction1, event: TKEvent.midiCC(trigger: .init(cc: 1)))
        
        let expectation = expectation(description: "testNonStandardRoundingUp")
        
        bus.addMapping(mapping) { payload in
            if payload.value == 0.11 {
                expectation.fulfill()
            }
        }
        
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value:.unitInterval(0.114), channel: 0))
        
        // Then
        defaultWaitForExpectations()
    }
    
    func testNonStandardRoundingDown() {
        // Given
        let config = TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps", decimalPlaces: 3)
        let bus = TKBus<TestAction>(config: config)
        let mapping = TKMapping(appAction: TestAction.testAction1, event: TKEvent.midiCC(trigger: .init(cc: 1)))
        
        let expectation = expectation(description: "testNonStandardRoundingUp")
        
        bus.addMapping(mapping) { payload in
            if payload.value == 0.111 {
                expectation.fulfill()
            }
        }
        
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value:.unitInterval(0.1114), channel: 0))
        
        // Then
        defaultWaitForExpectations()
    }

}
