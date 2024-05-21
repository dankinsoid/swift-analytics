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
}

extension Dictionary: WithAnalyticsParameters where Key == String, Value == Analytics.ParametersValue {

    public var parameters: Analytics.Parameters {
        get { self }
        set { self = newValue }
    }
}
