import Foundation

public struct NOOPAnalyticsHandler: AnalyticsHandler {

	public var parameters: [String: String] = [:]

	public static let instance = NOOPAnalyticsHandler()

	public init() {}

	public func send(event: Analytics.Event, file: String, function: String, line: UInt, source: String) {}
}
