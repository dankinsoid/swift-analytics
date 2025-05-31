import Foundation

public protocol WithAnalyticsParameters {

    /// The parameters associated with the analytics events.
    var parameters: Analytics.Parameters { get set }
}

public extension WithAnalyticsParameters {

    /// Removes the parameters associated with the analytics events.
    ///
    /// - Parameter keys: The keys of the parameters to be removed.
    /// - Returns: A new instance with the specified parameters removed.
    func without(_ key: String, _ rest: String...) -> Self {
        without([key] + rest)
    }

    /// Removes the parameters associated with the analytics events.
    ///
    /// - Parameter keys: The keys of the parameters to be removed.
    /// - Returns: A new instance with the specified parameters removed.
    func without(_ keys: [String]) -> Self {
        var copy = self
        for key in keys {
            copy.parameters.removeValue(forKey: key)
        }
        return copy
    }

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
    func with(_ key: String, _ value: Analytics.ParametersValue?) -> Self {
        if let value {
            return with([key: value])
        } else {
            return self
        }
    }

    /// Updates a single parameter associated with the analytics events using a `RawRepresentable` value.
    ///
    /// - Parameters:
    ///   - key: The key of the parameter to be updated.
    ///   - value: The `RawRepresentable` value of the parameter to be updated.
    func with<T: RawRepresentable>(_ key: String, _ value: T?) -> Self where T.RawValue == String {
        with(key, value.map { .string($0.rawValue) })
    }

    /// Updates a single parameter associated with the analytics events using a `Encodable` value.
    ///
    /// - Parameters:
    ///   - key: The key of the parameter to be updated.
    ///   - value: The `Encodable` value of the parameter to be updated.
    ///
    /// - Note: If the value cannot be encoded, it will be converted to a string representation. But this is highly unlikely to happen.
    @_disfavoredOverload
    func with<T: Encodable>(
        _ key: String,
        _ value: T?,
        encoder: ParametersValueEncoder = ParametersValueEncoder()
    ) -> Self {
        guard let value else {
            return self
        }
        do {
            return try with(key, encoder.encode(value))
        } catch {
            // highly unlikely to happen, encoding should succeed for most types
            return with(key, .string("\(value)"))
        }
    }

    /// Updates the parameters associated with the analytics events using a `Encodable` value.
    ///
    /// - Parameters:
    ///   - value: The `Encodable` value to be encoded and added to the parameters.
    ///
    /// - Warning: This method will throw an error if the value cannot be encoded into a dictionary.
    func with<T: Encodable>(
        _ value: T,
        encoder: ParametersValueEncoder = ParametersValueEncoder()
    ) throws -> Self {
        let parameters = try encoder.encode(value)
        guard case let .dictionary(dict) = parameters else {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Expected a dictionary for encoding, but got \(parameters)."
                )
            )
        }
        return with(dict)
    }

    /// Updates a single parameter associated with the analytics events using a `String` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `String` value of the parameter to be updated.
    func with(_ key: String, _ value: String?) -> Self {
        with(key, value.map { .string($0) })
    }

    /// Updates a single parameter associated with the analytics events using a `Bool` value.
    /// - Parameters:
    ///  - key: The key of the parameter to be updated.
    ///  - value: The `Bool` value of the parameter to be updated.
    func with(_ key: String, _ value: Bool?) -> Self {
        with(key, value.map { .bool($0) })
    }

    /// Updates a single parameter associated with the analytics events using a `Int` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `Int` value of the parameter to be updated.
    func with(_ key: String, _ value: Int?) -> Self {
        with(key, value.map { .int($0) })
    }

    /// Updates a single parameter associated with the analytics events using a `Double` value.
    /// - Parameters:
    /// - key: The key of the parameter to be updated.
    /// - value: The `Double` value of the parameter to be updated.
    func with(_ key: String, _ value: Double?) -> Self {
        with(key, value.map { .double($0) })
    }
}

extension [String: Analytics.ParametersValue]: WithAnalyticsParameters {

    public var parameters: Analytics.Parameters {
        get { self }
        set { self = newValue }
    }
}
