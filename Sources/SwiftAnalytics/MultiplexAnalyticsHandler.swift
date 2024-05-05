import Foundation

/// A pseudo-analytics handler that can be used to send messages to multiple other analytics handlers.
public struct MultiplexAnalyticsHandler: AnalyticsHandler {

	private var handlers: [AnalyticsHandler]

	public var parameters: [String: String] {
		get {
			Dictionary(handlers.flatMap { $0.parameters }) { _, last in last }
		}
		set {
			for i in handlers.indices {
				handlers[i].parameters = newValue
			}
		}
	}

	public init(handlers: [AnalyticsHandler]) {
		self.handlers = handlers
	}

	public func send(event: Analytics.Event, fileID: String, function: String, line: UInt) {
		for handler in handlers {
			handler.send(event: event, fileID: fileID, function: function, line: line)
		}
	}
}
