import Foundation

public struct NOOPAnalyticsHandler: AnalyticsHandler {

	public var parameters: Analytics.Parameters = [:]

	public static let instance = NOOPAnalyticsHandler()

	public init() {}

	public func send(event: Analytics.Event, file: String, function: String, line: UInt, source: String) {}
}
