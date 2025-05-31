import Foundation

/// A decoder that converts various formats to `Analytics.ParametersValue`.
public struct ParametersValueDecoder {
    
    public init() {}
    
    /// Decodes a `ParametersValue` from JSON data.
    public func decode(_ type: Analytics.ParametersValue.Type = Analytics.ParametersValue.self, from data: Data) throws -> Analytics.ParametersValue {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(Analytics.ParametersValue.self, from: data)
    }
    
    /// Decodes a `ParametersValue` from a JSON string.
    public func decode(_ type: Analytics.ParametersValue.Type = Analytics.ParametersValue.self, from string: String) throws -> Analytics.ParametersValue {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "Unable to convert string to UTF-8 data"
            ))
        }
        return try decode(type, from: data)
    }
    
    /// Decodes a `ParametersValue` from a dictionary or other Swift value.
    public func decode(_ type: Analytics.ParametersValue.Type = Analytics.ParametersValue.self, from value: Any) throws -> Analytics.ParametersValue {
        switch value {
        case let string as String:
            return .string(string)
        case let int as Int:
            return .int(int)
        case let double as Double:
            return .double(double)
        case let bool as Bool:
            return .bool(bool)
        case let array as [Any]:
            let parametersArray = try array.map { try decode(type, from: $0) }
            return .array(parametersArray)
        case let dictionary as [String: Any]:
            let parametersDict = try dictionary.mapValues { try decode(type, from: $0) }
            return .dictionary(parametersDict)
        default:
            throw DecodingError.typeMismatch(Analytics.ParametersValue.self, DecodingError.Context(
                codingPath: [],
                debugDescription: "Cannot decode value of type \(Swift.type(of: value)) to ParametersValue"
            ))
        }
    }
}
