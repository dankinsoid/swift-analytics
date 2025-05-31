import Foundation

/// A structure for handling analytics events and sending them to an analytics provider.
public struct Analytics: WithAnalyticsParameters {

    /// The analytics handler responsible for sending events.
    @usableFromInline
    var handler: AnalyticsHandler

    @usableFromInline
    let parametersProvider: ParametersProvider?

    /// The parameters associated with the analytics events.
    public var parameters: Analytics.Parameters {
        get { handler.parameters }
        set { handler.parameters = newValue }
    }

    /// Initializes the `Analytics` instance with the default analytics handler.
    public init(parametersProvider: ParametersProvider? = nil) {
        handler = AnalyticsSystem.handler
        let providers = [AnalyticsSystem.parametersProvider, parametersProvider].compactMap { $0 }
        switch providers.count {
        case 0:
            self.parametersProvider = nil
        case 1:
            self.parametersProvider = providers[0]
        default:
            self.parametersProvider = .multiplex(providers)
        }
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
        var event = event
        if let parameters = parametersProvider?.get(), !parameters.isEmpty {
            event.parameters.merge(parameters) { old, _ in old }
        }
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
        var event = event
        if let parameters = parametersProvider?.get(), !parameters.isEmpty {
            event.parameters.merge(parameters) { old, _ in old }
        }
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
    public struct Event: Equatable, Codable, Identifiable, WithAnalyticsParameters {

        public var id: String { name }
        /// The name of the analytics event.
        public var name: String
        /// The parameters associated with the analytics event.
        public var parameters: Analytics.Parameters

        /// Initializes an analytics event with the given name and parameters.
        ///
        /// - Parameters:
        ///   - name: The name of the event.
        ///   - parameters: The parameters associated with the event.
        public init(_ name: String, parameters: Analytics.Parameters = [:]) {
            self.name = name
            self.parameters = parameters
        }

        /// Initializes an analytics event with the given name and parameters.
        ///
        /// - Parameters:
        ///   - name: The name of the event.
        ///   - parameters: The parameters associated with the event as an `Encodable` type.
        ///
        /// - Throws: An error if the parameters cannot be encoded as a dictionary.
        public init<T: Encodable>(_ name: String, parameters: T, encoder: ParametersValueEncoder = ParametersValueEncoder()) throws {
            self = try Event(name).with(parameters, encoder: encoder)
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
        parameters: Analytics.Parameters = [:],
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
    func send(
        _ name: String,
        parameters: Analytics.Parameters = [:],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        source: @autoclosure () -> String? = nil
    ) {
        send(Event(name, parameters: parameters), file: file, function: function, line: line, source: source())
    }
    #endif
}

public extension Analytics {

    typealias Parameters = [String: ParametersValue]

    /// An analytics parameters value. `Analytics.ParametersValue` is string, array, and dictionary literal convertible.
    ///
    /// `ParametersValue` provides convenient conformances to `ExpressibleByStringInterpolation`,
    /// `ExpressibleByStringLiteral`, `ExpressibleByArrayLiteral`, and `ExpressibleByDictionaryLiteral` which means
    /// that when constructing `ParametersValue`s you should default to using Swift's usual literals.
    ///
    /// Examples:
    ///  - prefer `analytics.send("user logged in", parameters: ["user-id": "\(user.id)"])` over
    ///    `..., metadata: ["user-id": .string(user.id.description)])`
    ///  - prefer `analytics.send("user selected colors", parameters: ["colors": ["\(user.topColor)", "\(user.secondColor)"]])`
    ///    over `..., parameters: ["colors": .array([.string("\(user.topColor)"), .string("\(user.secondColor)")])`
    ///  - prefer `analytics.send("nested info", parameters: ["nested": ["fave-numbers": ["\(1)", "\(2)", "\(3)"], "foo": "bar"]])`
    ///    over `..., parameters: ["nested": .dictionary(["fave-numbers": ...])])`
    enum ParametersValue {
        /// A parameters value which is a `String`.
        ///
        /// Because `ParametersValue` implements `ExpressibleByStringInterpolation`, and `ExpressibleByStringLiteral`,
        /// you don't need to type `.string(someType.description)` you can use the string interpolation `"\(someType)"`.
        case string(String)

        /// A parameter value which is `Int`.
        case int(Int)

        /// A parameter value which is `Double`
        case double(Double)

        /// A parameter value which is `Bool`
        case bool(Bool)

        /// A parameters value which is a dictionary from `String` to `Logger.ParametersValue`.
        ///
        /// Because `ParametersValue` implements `ExpressibleByDictionaryLiteral`, you don't need to type
        /// `.dictionary(["foo": .string("bar \(buz)")])`, you can just use the more natural `["foo": "bar \(buz)"]`.
        case dictionary(Parameters)

        /// A parameters value which is an array of `Logger.ParametersValue`s.
        ///
        /// Because `ParametersValue` implements `ExpressibleByArrayLiteral`, you don't need to type
        /// `.array([.string("foo"), .string("bar \(buz)")])`, you can just use the more natural `["foo", "bar \(buz)"]`.
        case array([ParametersValue])
    }
}

extension Analytics.ParametersValue: Equatable {

    public static func == (lhs: Analytics.ParametersValue, rhs: Analytics.ParametersValue) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhs), .string(rhs)):
            return lhs == rhs
        case let (.int(lhs), .int(rhs)):
            return lhs == rhs
        case let (.double(lhs), .double(rhs)):
            return lhs == rhs
        case let (.bool(lhs), .bool(rhs)):
            return lhs == rhs
        case let (.array(lhs), .array(rhs)):
            return lhs == rhs
        case let (.dictionary(lhs), .dictionary(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

public extension Analytics.ParametersValue {

    var asAny: Any {
        switch self {
        case let .string(string):
            return string
        case let .int(int):
            return int
        case let .double(double):
            return double
        case let .bool(bool):
            return bool
        case let .array(array):
            return array.map { $0.asAny }
        case let .dictionary(dictionary):
            return dictionary.mapValues { $0.asAny }
        }
    }
}

#if compiler(>=5.6)
extension Analytics: Sendable {}
extension Analytics.Event: Sendable {}
extension Analytics.ParametersValue: Sendable {}
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

/// Extension has to be done on explicit type rather than Logger.Metadata.Value as workaround for
/// https://bugs.swift.org/browse/SR-9686
extension Analytics.ParametersValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

/// Extension has to be done on explicit type rather than Logger.Metadata.Value as workaround for
/// https://bugs.swift.org/browse/SR-9686
extension Analytics.ParametersValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .dictionary(dict):
            return dict.mapValues { $0.description }.description
        case let .array(list):
            return list.map { $0.description }.description
        case let .string(str):
            return str
        case let .int(int):
            return int.description
        case let .double(double):
            return double.description
        case let .bool(bool):
            return bool.description
        }
    }
}

extension Analytics.ParametersValue: ExpressibleByStringInterpolation {}

extension Analytics.ParametersValue: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension Analytics.ParametersValue: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Analytics.ParametersValue: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension Analytics.ParametersValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Analytics.ParametersValue

    public init(dictionaryLiteral elements: (String, Analytics.ParametersValue)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
}

extension Analytics.ParametersValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Analytics.ParametersValue

    public init(arrayLiteral elements: Analytics.ParametersValue...) {
        self = .array(elements)
    }
}

extension Analytics.ParametersValue: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(string):
            try string.encode(to: encoder)
        case let .int(int):
            try int.encode(to: encoder)
        case let .double(double):
            try double.encode(to: encoder)
        case let .bool(bool):
            try bool.encode(to: encoder)
        case let .array(array):
            try array.encode(to: encoder)
        case let .dictionary(dictionary):
            try dictionary.encode(to: encoder)
        }
    }
}

extension Analytics.ParametersValue: Decodable {

    public init(from decoder: Decoder) throws {
        do {
            self = try .array([Analytics.ParametersValue](from: decoder))
        } catch {
            do {
                self = try .dictionary(Analytics.Parameters(from: decoder))
            } catch {
                do {
                    self = try .int(Int(from: decoder))
                } catch {
                    do {
                        self = try .double(Double(from: decoder))
                    } catch {
                        do {
                            self = try .bool(Bool(from: decoder))
                        } catch {
                            self = try .string(String(from: decoder))
                        }
                    }
                }
            }
        }
    }
}
