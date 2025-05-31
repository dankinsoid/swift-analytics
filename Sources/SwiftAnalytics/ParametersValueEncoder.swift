import Foundation

/// An encoder that converts any `Encodable` type to `Analytics.ParametersValue`.
public struct ParametersValueEncoder {
    
    /// The strategy to use for encoding `Date` values.
    public var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    
    /// The strategy to use for encoding `Data` values.
    public var dataEncodingStrategy: DataEncodingStrategy = .base64
    
    /// The strategy to use for converting keys.
    public var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
    
    public init() {}

    /// Encodes any `Encodable` value to `Analytics.ParametersValue`.
    public func encode<T: Encodable>(_ value: T) throws -> Analytics.ParametersValue {
        let encoder = _ParametersValueEncoder(
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy
        )
        try value.encode(to: encoder)
        return encoder.result
    }
}

public extension ParametersValueEncoder {
    
    /// The strategy to use for encoding `Date` values.
    enum DateEncodingStrategy {
        /// Defer to `Date` for choosing an encoding. This is the default strategy.
        case deferredToDate
        
        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970
        
        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970
        
        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        case iso8601
        
        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)
        
        /// Encode the `Date` as a custom value encoded by the given closure.
        case custom((Date, Encoder) throws -> Void)
    }
    
    /// The strategy to use for encoding `Data` values.
    enum DataEncodingStrategy {
        /// Defer to `Data` for choosing an encoding.
        case deferredToData
        
        /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Encode the `Data` as a custom value encoded by the given closure.
        case custom((Data, Encoder) throws -> Void)
    }
    
    /// The strategy to use for automatically changing the value of keys before encoding.
    enum KeyEncodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys
        
        /// Convert from "camelCase" to "snake_case".
        case convertToSnakeCase
        
        /// Provide a custom conversion from the key in the encoded type to the key in the encoded JSON.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
    }
}

private final class _ParametersValueEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var result: Analytics.ParametersValue = .string("")
    
    let dateEncodingStrategy: ParametersValueEncoder.DateEncodingStrategy
    let dataEncodingStrategy: ParametersValueEncoder.DataEncodingStrategy
    let keyEncodingStrategy: ParametersValueEncoder.KeyEncodingStrategy
    
    init(
        dateEncodingStrategy: ParametersValueEncoder.DateEncodingStrategy,
        dataEncodingStrategy: ParametersValueEncoder.DataEncodingStrategy,
        keyEncodingStrategy: ParametersValueEncoder.KeyEncodingStrategy
    ) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        result = .dictionary([:])
        let container = _KeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        result = .array([])
        return _UnkeyedEncodingContainer(encoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        result = .string("")
        return _SingleValueEncodingContainer(encoder: self)
    }
}

private struct _KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] { encoder.codingPath }
    private let encoder: _ParametersValueEncoder
    private var storage: [String: Analytics.ParametersValue] = [:]

    init(encoder: _ParametersValueEncoder) {
        self.encoder = encoder
    }

    mutating func encodeNil(forKey key: Key) throws {
        // ParametersValue doesn't support nil, so we skip it
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        storage[key.stringValue] = .bool(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        storage[key.stringValue] = .string(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        storage[key.stringValue] = .double(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        storage[key.stringValue] = .double(Double(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        storage[key.stringValue] = .int(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        storage[key.stringValue] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        let encodedKey = encoder.keyEncodingStrategy.encode(key, codingPath: codingPath)
        
        // Handle special types
        if let date = value as? Date {
            storage[encodedKey] = try encoder.encodeDate(date)
        } else if let data = value as? Data {
            storage[encodedKey] = try encoder.encodeData(data)
        } else if let url = value as? URL {
            storage[encodedKey] = .string(url.absoluteString)
        } else if let decimal = value as? Decimal {
            storage[encodedKey] = .string(decimal.description)
        } else {
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: encoder.dateEncodingStrategy,
                dataEncodingStrategy: encoder.dataEncodingStrategy,
                keyEncodingStrategy: encoder.keyEncodingStrategy
            )
            subEncoder.codingPath = codingPath + [key]
            try value.encode(to: subEncoder)
            storage[encodedKey] = subEncoder.result
        }
        encoder.result = .dictionary(storage)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let subEncoder = _ParametersValueEncoder()
        subEncoder.codingPath = codingPath + [key]
        let container = _KeyedEncodingContainer<NestedKey>(encoder: subEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let subEncoder = _ParametersValueEncoder()
        subEncoder.codingPath = codingPath + [key]
        return _UnkeyedEncodingContainer(encoder: subEncoder)
    }

    mutating func superEncoder() -> Encoder {
        encoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        let subEncoder = _ParametersValueEncoder()
        subEncoder.codingPath = codingPath + [key]
        return subEncoder
    }
}

private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] { encoder.codingPath }
    var count: Int { storage.count }

    private let encoder: _ParametersValueEncoder
    private var storage: [Analytics.ParametersValue] = []

    init(encoder: _ParametersValueEncoder) {
        self.encoder = encoder
    }

    mutating func encodeNil() throws {
        // ParametersValue doesn't support nil, so we skip it
    }

    mutating func encode(_ value: Bool) throws {
        storage.append(.bool(value))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: String) throws {
        storage.append(.string(value))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Double) throws {
        storage.append(.double(value))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Float) throws {
        storage.append(.double(Double(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Int) throws {
        storage.append(.int(value))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Int8) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Int16) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Int32) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: Int64) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: UInt) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: UInt8) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: UInt16) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: UInt32) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode(_ value: UInt64) throws {
        storage.append(.int(Int(value)))
        encoder.result = .array(storage)
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        // Handle special types
        if let date = value as? Date {
            storage.append(try encoder.encodeDate(date))
        } else if let data = value as? Data {
            storage.append(try encoder.encodeData(data))
        } else if let url = value as? URL {
            storage.append(.string(url.absoluteString))
        } else if let decimal = value as? Decimal {
            storage.append(.string(decimal.description))
        } else {
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: encoder.dateEncodingStrategy,
                dataEncodingStrategy: encoder.dataEncodingStrategy,
                keyEncodingStrategy: encoder.keyEncodingStrategy
            )
            try value.encode(to: subEncoder)
            storage.append(subEncoder.result)
        }
        encoder.result = .array(storage)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let subEncoder = _ParametersValueEncoder()
        let container = _KeyedEncodingContainer<NestedKey>(encoder: subEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let subEncoder = _ParametersValueEncoder()
        return _UnkeyedEncodingContainer(encoder: subEncoder)
    }

    mutating func superEncoder() -> Encoder {
        encoder
    }
}

private struct _SingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] { encoder.codingPath }

    private let encoder: _ParametersValueEncoder

    init(encoder: _ParametersValueEncoder) {
        self.encoder = encoder
    }

    mutating func encodeNil() throws {
        // ParametersValue doesn't support nil
        throw EncodingError.invalidValue(Any?.none as Any, EncodingError.Context(
            codingPath: codingPath,
            debugDescription: "ParametersValue does not support nil values"
        ))
    }

    mutating func encode(_ value: Bool) throws {
        encoder.result = .bool(value)
    }

    mutating func encode(_ value: String) throws {
        encoder.result = .string(value)
    }

    mutating func encode(_ value: Double) throws {
        encoder.result = .double(value)
    }

    mutating func encode(_ value: Float) throws {
        encoder.result = .double(Double(value))
    }

    mutating func encode(_ value: Int) throws {
        encoder.result = .int(value)
    }

    mutating func encode(_ value: Int8) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: Int16) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: Int32) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: Int64) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: UInt) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: UInt8) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: UInt16) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: UInt32) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode(_ value: UInt64) throws {
        encoder.result = .int(Int(value))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        // Handle special types
        if let date = value as? Date {
            encoder.result = try encoder.encodeDate(date)
        } else if let data = value as? Data {
            encoder.result = try encoder.encodeData(data)
        } else if let url = value as? URL {
            encoder.result = .string(url.absoluteString)
        } else if let decimal = value as? Decimal {
            encoder.result = .string(decimal.description)
        } else {
            try value.encode(to: encoder)
        }
    }
}

// MARK: - Helper Extensions

private extension _ParametersValueEncoder {
    
    func encodeDate(_ date: Date) throws -> Analytics.ParametersValue {
        switch dateEncodingStrategy {
        case .deferredToDate:
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy
            )
            subEncoder.codingPath = codingPath
            try date.encode(to: subEncoder)
            return subEncoder.result
            
        case .secondsSince1970:
            return .double(date.timeIntervalSince1970)
            
        case .millisecondsSince1970:
            return .double(date.timeIntervalSince1970 * 1000.0)
            
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return .string(ISO8601DateFormatter().string(from: date))
            } else {
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                return .string(formatter.string(from: date))
            }
            
        case .formatted(let formatter):
            return .string(formatter.string(from: date))
            
        case .custom(let closure):
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy
            )
            subEncoder.codingPath = codingPath
            try closure(date, subEncoder)
            return subEncoder.result
        }
    }
    
    func encodeData(_ data: Data) throws -> Analytics.ParametersValue {
        switch dataEncodingStrategy {
        case .deferredToData:
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy
            )
            subEncoder.codingPath = codingPath
            try data.encode(to: subEncoder)
            return subEncoder.result
            
        case .base64:
            return .string(data.base64EncodedString())
            
        case .custom(let closure):
            let subEncoder = _ParametersValueEncoder(
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy
            )
            subEncoder.codingPath = codingPath
            try closure(data, subEncoder)
            return subEncoder.result
        }
    }
}

private extension ParametersValueEncoder.KeyEncodingStrategy {
    
    func encode<Key: CodingKey>(_ key: Key, codingPath: [CodingKey]) -> String {
        switch self {
        case .useDefaultKeys:
            return key.stringValue
            
        case .convertToSnakeCase:
            return convertToSnakeCase(key.stringValue)
            
        case .custom(let closure):
            return closure(codingPath + [key]).stringValue
        }
    }
    
    private func convertToSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }
        
        var result = ""
        var previousCharacterWasUppercase = false
        
        for (index, character) in stringKey.enumerated() {
            if character.isUppercase {
                if index > 0 && !previousCharacterWasUppercase {
                    result += "_"
                }
                result += character.lowercased()
                previousCharacterWasUppercase = true
            } else {
                result += String(character)
                previousCharacterWasUppercase = false
            }
        }
        
        return result
    }
}
