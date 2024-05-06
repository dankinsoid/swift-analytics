@testable import SwiftAnalytics
import XCTest

final class AnalyticsTests: XCTestCase {
    
    static var allTests = [
        ("testSendEventWithNameAndParameters", testSendEventWithNameAndParameters),
        ("testWithParameters", testWithParameters),
    ]

	let handler = MockAnalyticsHandler()

	override func setUp() {
		super.setUp()
        AnalyticsSystem.bootstrapInternal(self.handler)
	}

	func testSendEventWithNameAndParameters() {
		let eventName = "Test Event"
		let parameters = ["param1": "value1", "param2": "value2"]

		// Act
		Analytics().send(eventName, parameters: parameters)

		// Assert
		XCTAssertEqual(handler.events.last?.name, eventName)
		XCTAssertEqual(handler.events.last?.parameters, parameters)
	}

	func testWithParameters() {
		// Arrange
		var analytics = Analytics()

		let initialParameters = ["param1": "value1"]
		let updatedParameters = ["param2": "value2"]

		// Act
		let analyticsWithUpdatedParams = analytics.with(updatedParameters)

		// Assert
		XCTAssertEqual(analyticsWithUpdatedParams.parameters, updatedParameters)
		XCTAssertNotEqual(analyticsWithUpdatedParams.parameters, initialParameters)
	}
}
