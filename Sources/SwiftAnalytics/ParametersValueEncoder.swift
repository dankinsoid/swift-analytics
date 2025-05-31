import Foundation

/// An encoder that converts any `Encodable` type to `Analytics.ParametersValue`.
public struct ParametersValueEncoder {
    
    public init() {}
    
    /// Encodes any `Encodable` value to `Analytics.ParametersValue`.
    public func encode<T: Encodable>(_ value: T) throws -> Analytics.ParametersValue {
        let encoder = _ParametersValueEncoder()
        try value.encode(to: encoder)
        return encoder.result
    }
}

private final class _ParametersValueEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var result: Analytics.ParametersValue = .string("")
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = _KeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _UnkeyedEncodingContainer(encoder: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
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
        let subEncoder = _ParametersValueEncoder()
        subEncoder.codingPath = codingPath + [key]
        try value.encode(to: subEncoder)
        storage[key.stringValue] = subEncoder.result
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
        return encoder
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
        let subEncoder = _ParametersValueEncoder()
        try value.encode(to: subEncoder)
        storage.append(subEncoder.result)
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
        return encoder
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
        throw EncodingError.invalidValue(Optional<Any>.none as Any, EncodingError.Context(
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
        try value.encode(to: encoder)
    }
}
