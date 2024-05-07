import Foundation

/// Mock AnalyticsHandler for testing
public final class MockAnalyticsHandler: AnalyticsHandler {

	public var parameters: [String: String]
	public var events: [Analytics.Event] = []

	public init(parameters: [String: String] = [:]) {
		self.parameters = parameters
	}

    public func send(event: Analytics.Event, file: String, function: String, line: UInt, source: String) {
		events.append(event)
	}
}
