import Foundation

/// A structure for handling analytics events and sending them to an analytics provider.
public struct Analytics {

	/// The analytics handler responsible for sending events.
	@usableFromInline
	var handler: AnalyticsHandler

	/// The parameters associated with the analytics events.
	public var parameters: [String: String] {
		get { handler.parameters }
		set { handler.parameters = newValue }
	}

	/// Initializes the `Analytics` instance with the default analytics handler.
	public init() {
		handler = AnalyticsSystem.handler
	}

#if compiler(>=5.3)
	/// Sends an analytics event.
	///
	/// - Parameters:
	///   - event: The analytics event to be sent.
    @inlinable
	public func send(
		_ event: Event,
		file: String = #fileID,
		function: String = #function,
		line: UInt = #line,
        source: @autoclosure () -> String? = nil
	) {
        handler.send(
            event: event,
            file: file,
            function: function,
            line: line,
            source: source() ?? Analytics.currentModule(fileID: file)
        )
	}
#else
    @inlinable
    public func send(
        _ event: Event,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        source: @autoclosure () -> String? = nil
    ) {
        handler.send(
            event: event,
            file: file,
            function: function,
            line: line,
            source: source() ?? Analytics.currentModule(filePath: file)
        )
    }
#endif

	/// A structure representing an analytics event.
	public struct Event: Hashable, Codable {

		/// The name of the analytics event.
		public var name: String
		/// The parameters associated with the analytics event.
		public var parameters: [String: String]

		/// Initializes an analytics event with the given name and parameters.
		///
		/// - Parameters:
		///   - name: The name of the event.
		///   - parameters: The parameters associated with the event.
		public init(_ name: String, parameters: [String: CustomStringConvertible] = [:]) {
			self.name = name
			self.parameters = parameters.mapValues(\.description)
		}
	}
}

public extension Analytics {

#if compiler(>=5.3)
	/// Sends an analytics event with the given name and parameters.
	///
	/// - Parameters:
	///   - name: The name of the event.
	///   - parameters: The parameters associated with the event.
    @inlinable
	func send(
		_ name: String,
		parameters: [String: CustomStringConvertible] = [:],
		file: String = #fileID,
		function: String = #function,
		line: UInt = #line,
        source: @autoclosure () -> String? = nil
	) {
		send(Event(name, parameters: parameters), file: file, function: function, line: line, source: source())
	}
#else
    /// Sends an analytics event with the given name and parameters.
    ///
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - parameters: The parameters associated with the event.
    @inlinable
    public func send(
        _ name: String,
        parameters: [String: CustomStringConvertible] = [:],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        source: @autoclosure () -> String? = nil
    ) {
        send(Event(name, parameters: parameters), file: file, function: function, line: line, source: source())
    }
#endif

	/// Updates the parameters associated with the analytics events and returns a new instance of `Analytics`.
	///
	/// - Parameter parameters: The parameters to be updated.
	/// - Returns: A new instance of `Analytics` with the updated parameters.
	func with(_ parameters: [String: CustomStringConvertible]) -> Self {
		var copy = self
		copy.parameters = parameters.mapValues(\.description)
		return copy
	}

	/// Updates a single parameter associated with the analytics events and returns a new instance of `Analytics`.
	///
	/// - Parameters:
	///   - key: The key of the parameter to be updated.
	///   - value: The value of the parameter to be updated.
	/// - Returns: A new instance of `Analytics` with the updated parameter.
	@_disfavoredOverload
	func with(_ key: String, _ value: CustomStringConvertible) -> Self {
		with([key: value])
	}

	/// Updates a single parameter associated with the analytics events using a `RawRepresentable` value and returns a new instance of `Analytics`.
	///
	/// - Parameters:
	///   - key: The key of the parameter to be updated.
	///   - value: The `RawRepresentable` value of the parameter to be updated.
	/// - Returns: A new instance of `Analytics` with the updated parameter.
	func with<T: RawRepresentable>(_ key: String, _ value: T) -> Self where T.RawValue: CustomStringConvertible {
		with([key: value.rawValue])
	}
}

#if compiler(>=5.6)
extension Analytics: Sendable {}
extension Analytics.Event: Sendable {}
#endif

extension Analytics {
    
    @inlinable
    static func currentModule(filePath: String = #file) -> String {
        let utf8All = filePath.utf8
        return filePath.utf8.lastIndex(of: UInt8(ascii: "/")).flatMap { lastSlash -> Substring? in
            utf8All[..<lastSlash].lastIndex(of: UInt8(ascii: "/")).map { secondLastSlash -> Substring in
                filePath[utf8All.index(after: secondLastSlash) ..< lastSlash]
            }
        }.map {
            String($0)
        } ?? "n/a"
    }
    
#if compiler(>=5.3)
    @inlinable
    static func currentModule(fileID: String = #fileID) -> String {
        let utf8All = fileID.utf8
        if let slashIndex = utf8All.firstIndex(of: UInt8(ascii: "/")) {
            return String(fileID[..<slashIndex])
        } else {
            return "n/a"
        }
    }
#endif
}
