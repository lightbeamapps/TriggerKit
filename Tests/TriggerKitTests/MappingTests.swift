import XCTest
@testable import TriggerKit

final class MappingTests: XCTestCase {
    
    private func createConfig() -> TKBusConfig {
        TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps")
    }
    
    enum TestAction: TKAppActionConstraints {
        case testAction1
        case testAction2
        case testAction3
    }
    
    var bus: TKBus<TestAction>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        bus = TKBus<TestAction>(config: self.createConfig())
    }
    
    func testAddingAMapping() {
        // Given
        let expectation = self.expectation(description: "testAddingAMapping - called")
        let event = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping = TKMapping(appAction: TestAction.testAction1, event: event)
        
        bus.addMapping(mapping) { payload in
            if payload.value == 0.5 {
                expectation.fulfill()
            }
        }
        
        // We have to wait for the main thread for our mapping to be active
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value: .unitInterval(0.5), channel: 0))
        
        // Then
        self.defaultWaitForExpectations()
    }
    
    func testRemovingAMapping() {
        // Given
        let event = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping = TKMapping(appAction: TestAction.testAction1, event: event)
        
        bus.addMapping(mapping) { _ in
            // do nothing
        }
        
        // We have to wait for the main thread for our mapping to be active
        waitForMainThread()
        
        XCTAssertEqual(bus.mappings.first, mapping)
        XCTAssertEqual(bus.mappings.count, 1)
        
        // When
        bus.removeMapping(mapping)
        
        // We have to wait for the main thread for our mapping to be removed
        waitForMainThread()
                        
        // Then
        XCTAssertNil(bus.mappings.first)
        XCTAssertTrue(bus.mappings.isEmpty)
    }
    
    func testUpdatingAMapping() {
        // Given
        let event1 = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping1 = TKMapping(appAction: TestAction.testAction1, event: event1)
        let event2 = TKEvent.midiCC(trigger: .init(cc: 2))
        let mapping2 = TKMapping(appAction: TestAction.testAction2, event: event2)

        bus.addMapping(mapping1, callback: { _ in })
        bus.addMapping(mapping2, callback: { _ in })

        // We have to wait for the main thread for our mapping to be active
        waitForMainThread()
        
        XCTAssertEqual(bus.mappings[0], mapping1)
        XCTAssertEqual(bus.mappings[1], mapping2)
        XCTAssertEqual(bus.mappings.count, 2)
        XCTAssertEqual(bus.mappings[0].event, event1)
        XCTAssertEqual(bus.mappings[1].event, event2)
        
        // When
        let updatedEvent1 = TKEvent.midiNote(trigger: .init(note: 1, noteString: "1"))
        var mapping1_Updated = mapping1
        mapping1_Updated.event = updatedEvent1
        
        bus.addMapping(mapping1_Updated, callback: { _ in })
                
        // We have to wait for the main thread for our mapping to be removed
        waitForMainThread()
                        
        // Then
        XCTAssertEqual(bus.mappings[0], mapping1_Updated)
        XCTAssertEqual(bus.mappings[1], mapping2)
        XCTAssertEqual(bus.mappings.count, 2)
        XCTAssertEqual(bus.mappings[0].event, updatedEvent1)
        XCTAssertEqual(bus.mappings[1].event, event2)
    }
    
    func testAddingANewMapping() {
        // Given
        let event1 = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping1 = TKMapping(appAction: TestAction.testAction1, event: event1)
        let event2 = TKEvent.midiCC(trigger: .init(cc: 2))
        let mapping2 = TKMapping(appAction: TestAction.testAction2, event: event2)

        bus.addMapping(mapping1, callback: { _ in })
        bus.addMapping(mapping2, callback: { _ in })

        // We have to wait for the main thread for our mapping to be active
        waitForMainThread()
        
        XCTAssertEqual(bus.mappings[0], mapping1)
        XCTAssertEqual(bus.mappings[1], mapping2)
        XCTAssertEqual(bus.mappings.count, 2)
        XCTAssertEqual(bus.mappings[0].event, event1)
        XCTAssertEqual(bus.mappings[1].event, event2)
        
        let newEvent = TKEvent.midiNote(trigger: .init(note: 1, noteString: "1"))
        let newMapping = TKMapping(appAction: TestAction.testAction3, event: newEvent)
        
        bus.addMapping(newMapping, callback: { _ in })
                
        // We have to wait for the main thread for our mapping to be removed
        waitForMainThread()
                        
        // Then
        XCTAssertEqual(bus.mappings[0], mapping1)
        XCTAssertEqual(bus.mappings[1], mapping2)
        XCTAssertEqual(bus.mappings[2], newMapping)
        XCTAssertEqual(bus.mappings.count, 3)
        XCTAssertEqual(bus.mappings[0].event, event1)
        XCTAssertEqual(bus.mappings[1].event, event2)
        XCTAssertEqual(bus.mappings[2].event, newEvent)
    }
    
    func testDuplicatingAMapping() {
        // Given
        let event1 = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping1 = TKMapping(appAction: TestAction.testAction1, event: event1)
        let mappingDupe = TKMapping(appAction: TestAction.testAction1, event: event1)
        
        XCTAssertTrue(bus.mappings.isEmpty)

        // When
        bus.addMapping(mapping1, callback: { _ in })
        bus.addMapping(mappingDupe, callback: { _ in })

        // We have to wait for the main thread for our mappings to be active
        waitForMainThread()
        
        // Then we should have both in the bus's mapping
        XCTAssertEqual(bus.mappings[0], mapping1)
        XCTAssertEqual(bus.mappings[1], mappingDupe)
        XCTAssertEqual(bus.mappings.count, 2)
        XCTAssertEqual(bus.mappings[0].event, event1)
        XCTAssertEqual(bus.mappings[1].event, event1)
    }
    
    func testDuplicatingAMappingTriggersBothCallbacks() {
        // Given
        let event1 = TKEvent.midiCC(trigger: .init(cc: 1))
        let mapping1 = TKMapping(appAction: TestAction.testAction1, event: event1)
        let mappingDupe = TKMapping(appAction: TestAction.testAction1, event: event1)
        
        XCTAssertTrue(bus.mappings.isEmpty)
        
        let expectation1 = expectation(description: "expectation1")
        let expectation2 = expectation(description: "expectation2")

        bus.addMapping(mapping1, callback: { _ in
            expectation1.fulfill()
        })
        
        bus.addMapping(mappingDupe, callback: { _ in
            expectation2.fulfill()
        })

        // We have to wait for the main thread for our mappings to be active
        waitForMainThread()
        
        // When
        bus.handleMidiEvent(.cc(1, value: .unitInterval(0.5), channel: 0))
        
        waitForMainThread()

        // Then
        defaultWaitForExpectations()
    }
}
