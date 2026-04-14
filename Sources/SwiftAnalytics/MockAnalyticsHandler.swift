import Foundation

/// Mock AnalyticsHandler for testing
public final class MockAnalyticsHandler: @unchecked Sendable, AnalyticsHandler {
	
	private let lock = ReadWriteLock()
	public var parameters: Analytics.Parameters
	public var events: [Analytics.Event] = []

	public init(parameters: Analytics.Parameters = [:]) {
		self.parameters = parameters
	}

	public func send(event: Analytics.Event, file: String, function: String, line: UInt, source: String) {
		lock.withWriterLock {
			events.append(event)
		}
	}
}
