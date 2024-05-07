import Foundation

/// A pseudo-analytics handler that can be used to send messages to multiple other analytics handlers.
public struct MultiplexAnalyticsHandler: AnalyticsHandler {

	private var handlers: [AnalyticsHandler]

	public var parameters: Analytics.Parameters {
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

	public func send(event: Analytics.Event, file: String, function: String, line: UInt, source: String) {
		for handler in handlers {
			handler.send(event: event, file: file, function: function, line: line, source: source)
		}
	}
}
