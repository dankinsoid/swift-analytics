import Foundation

/// An encoder that converts `Analytics.ParametersValue` to various formats.
public struct ParametersValueEncoder {
    
    public init() {}
    
    /// Encodes a `ParametersValue` to JSON data.
    public func encode(_ value: Analytics.ParametersValue) throws -> Data {
        let jsonEncoder = JSONEncoder()
        return try jsonEncoder.encode(value)
    }
    
    /// Encodes a `ParametersValue` to a JSON string.
    public func encodeToString(_ value: Analytics.ParametersValue) throws -> String {
        let data = try encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: [],
                debugDescription: "Unable to convert encoded data to UTF-8 string"
            ))
        }
        return string
    }
    
    /// Encodes a `ParametersValue` to a dictionary representation.
    public func encodeToDictionary(_ value: Analytics.ParametersValue) -> Any {
        return value.asAny
    }
}
