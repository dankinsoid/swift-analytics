import Foundation

public protocol WithAnalyticsParameters {

    /// The parameters associated with the analytics events.
    var parameters: Analytics.Parameters { get set }
}

public extension WithAnalyticsParameters {

    /// Updates the parameters associated with the analytics events.
    ///
    /// - Parameter parameters: The parameters to be updated.
    func with(_ parameters: Analytics.Parameters) -> Self {
        var copy = self
        copy.parameters.merge(parameters) { _, p in p }
        return copy
    }

    /// Updates a single parameter associated with the analytics events`.
    ///
    /// - Parameters:
    ///   - key: The key of the parameter to be updated.
    ///   - value: The value of the parameter to be updated.
    func with(_ key: String, _ value: Analytics.ParametersValue) -> Self {
        with([key: value])
    }

    /// Updates a single parameter associated with the analytics events using a `RawRepresentable` value.
    ///
    /// - Parameters:
    ///   - key: The key of the parameter to be updated.
    ///   - value: The `RawRepresentable` value of the parameter to be updated.
    func with<T: RawRepresentable>(_ key: String, _ value: T) -> Self where T.RawValue == String {
        with([key: .string(value.rawValue)])
    }

    /// Updates a single parameter associated with the analytics events using a `String` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `String` value of the parameter to be updated.
    func with(_ key: String, _ value: String) -> Self {
        with([key: .string(value)])
    }

    /// Updates a single parameter associated with the analytics events using a `Bool` value.
    /// - Parameters:
    ///  - key: The key of the parameter to be updated.
    ///  - value: The `Bool` value of the parameter to be updated.
    func with(_ key: String, _ value: Bool) -> Self {
        with([key: .bool(value)])
    }

    /// Updates a single parameter associated with the analytics events using a `Int` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `Int` value of the parameter to be updated.
    func with(_ key: String, _ value: Int) -> Self {
        with([key: .int(value)])
    }

    /// Updates a single parameter associated with the analytics events using a `Double` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `Double` value of the parameter to be updated.
    func with(_ key: String, _ value: Double) -> Self {
        with([key: .double(value)])
    }
}

extension Dictionary: WithAnalyticsParameters where Key == String, Value == Analytics.ParametersValue {

    public var parameters: Analytics.Parameters {
        get { self }
        set { self = newValue }
    }
}
