import Foundation

/// An `AnalyticsHandler` is an implementation of a analytics backend.
///
/// This type is an implementation detail and should not normally be used, unless implementing your own analytics backend backend.
/// To use the SwiftLog API, please refer to the documentation of ``Analytics``.
///
/// # Implementation requirements
///
/// To implement your own `AnalyticsHandler` you should respect a few requirements that are necessary so applications work
/// as expected regardless of the selected `AnalyticsHandler` implementation.
///
/// - The ``AnalyticsHandler`` must be a `struct`.
/// - The parameters property must be implemented so that setting it on an `AnalyticsHandler` does not affect
///   other `AnalyticsHandler`s.
///
/// ### Treat parameters as values
///
/// When developing your `AnalyticsHandler`, please make sure the following test works.
///
/// ```swift
/// AnalyticsSystem.bootstrap(MyAnalyticsHandler()) // your AnalyticsHandler might have a different bootstrapping step
/// var analytics1 = Analytics()
/// analytics1.parameters["only-on"] = "first"
///
/// var analytics2 = analytics1
/// analytics2.parameters["only-on"] = "second" // this must not override `analytics2`'s parameters
///
/// XCTAssertEqual("first", analytics1.parameters["only-on"])
/// XCTAssertEqual("second", analytics2.parameters["only-on"])
/// ```
public protocol AnalyticsHandler: _SwiftAnalyticsSendableAnalyticsHandler {

	/// The parameters that will be included in all analytics events sent by this handler.
	var parameters: [String: String] { get set }
	/// Send an analytics event to the backend.
	func send(event: Analytics.Event, fileID: String, function: String, line: UInt)
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
@preconcurrency public protocol _SwiftAnalyticsSendableAnalyticsHandler: Sendable {}
#else
public protocol _SwiftAnalyticsSendableAnalyticsHandler {}
#endif
