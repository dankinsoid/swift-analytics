import Foundation

/// A decoder that converts `Analytics.ParametersValue` to any `Decodable` type.
public struct ParametersValueDecoder {
    
    public init() {}
    
    /// Decodes any `Decodable` type from `Analytics.ParametersValue`.
    public func decode<T: Decodable>(_ type: T.Type, from value: Analytics.ParametersValue) throws -> T {
        let decoder = _ParametersValueDecoder(value: value)
        return try T(from: decoder)
    }
}

private final class _ParametersValueDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    
    private let value: Analytics.ParametersValue
    
    init(value: Analytics.ParametersValue, codingPath: [CodingKey] = []) {
        self.value = value
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        guard case let .dictionary(dict) = value else {
            throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected dictionary but found \(value)"
            ))
        }
        let container = _KeyedDecodingContainer<Key>(decoder: self, dictionary: dict)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard case let .array(array) = value else {
            throw DecodingError.typeMismatch([Any].self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected array but found \(value)"
            ))
        }
        return _UnkeyedDecodingContainer(decoder: self, array: array)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _SingleValueDecodingContainer(decoder: self, value: value)
    }
}

private struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] { decoder.codingPath }
    var allKeys: [Key] {
        dictionary.keys.compactMap { Key(stringValue: $0) }
    }
    
    private let decoder: _ParametersValueDecoder
    private let dictionary: Analytics.Parameters
    
    init(decoder: _ParametersValueDecoder, dictionary: Analytics.Parameters) {
        self.decoder = decoder
        self.dictionary = dictionary
    }
    
    func contains(_ key: Key) -> Bool {
        dictionary[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        guard case let .bool(boolValue) = value else {
            throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected Bool but found \(value)"
            ))
        }
        return boolValue
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        guard case let .string(stringValue) = value else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected String but found \(value)"
            ))
        }
        return stringValue
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        switch value {
        case let .double(doubleValue):
            return doubleValue
        case let .int(intValue):
            return Double(intValue)
        default:
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected Double but found \(value)"
            ))
        }
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return Float(try decode(Double.self, forKey: key))
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        guard case let .int(intValue) = value else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected Int but found \(value)"
            ))
        }
        return intValue
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return Int8(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return Int16(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return Int32(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return Int64(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return UInt(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return UInt8(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return UInt16(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return UInt32(try decode(Int.self, forKey: key))
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return UInt64(try decode(Int.self, forKey: key))
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath + [key])
        return try T(from: subDecoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath + [key])
        return try subDecoder.container(keyedBy: type)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath + [key])
        return try subDecoder.unkeyedContainer()
    }
    
    func superDecoder() throws -> Decoder {
        return decoder
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        return _ParametersValueDecoder(value: value, codingPath: codingPath + [key])
    }
}

private struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] { decoder.codingPath }
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex: Int = 0
    
    private let decoder: _ParametersValueDecoder
    private let array: [Analytics.ParametersValue]
    
    init(decoder: _ParametersValueDecoder, array: [Analytics.ParametersValue]) {
        self.decoder = decoder
        self.array = array
    }
    
    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        return false // ParametersValue doesn't support nil
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        guard case let .bool(boolValue) = value else {
            throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Bool but found \(value)"
            ))
        }
        return boolValue
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        guard case let .string(stringValue) = value else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected String but found \(value)"
            ))
        }
        return stringValue
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Double.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        switch value {
        case let .double(doubleValue):
            return doubleValue
        case let .int(intValue):
            return Double(intValue)
        default:
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Double but found \(value)"
            ))
        }
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        return Float(try decode(Double.self))
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        guard case let .int(intValue) = value else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Int but found \(value)"
            ))
        }
        return intValue
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return Int8(try decode(Int.self))
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return Int16(try decode(Int.self))
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return Int32(try decode(Int.self))
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return Int64(try decode(Int.self))
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return UInt(try decode(Int.self))
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return UInt8(try decode(Int.self))
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return UInt16(try decode(Int.self))
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return UInt32(try decode(Int.self))
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return UInt64(try decode(Int.self))
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath)
        return try T(from: subDecoder)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath)
        return try subDecoder.container(keyedBy: type)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        let subDecoder = _ParametersValueDecoder(value: value, codingPath: codingPath)
        return try subDecoder.unkeyedContainer()
    }
    
    mutating func superDecoder() throws -> Decoder {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1
        return _ParametersValueDecoder(value: value, codingPath: codingPath)
    }
}

private struct _SingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] { decoder.codingPath }
    
    private let decoder: _ParametersValueDecoder
    private let value: Analytics.ParametersValue
    
    init(decoder: _ParametersValueDecoder, value: Analytics.ParametersValue) {
        self.decoder = decoder
        self.value = value
    }
    
    func decodeNil() -> Bool {
        false // ParametersValue doesn't support nil
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard case let .bool(boolValue) = value else {
            throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Bool but found \(value)"
            ))
        }
        return boolValue
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard case let .string(stringValue) = value else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected String but found \(value)"
            ))
        }
        return stringValue
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        switch value {
        case let .double(doubleValue):
            return doubleValue
        case let .int(intValue):
            return Double(intValue)
        default:
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Double but found \(value)"
            ))
        }
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        return Float(try decode(Double.self))
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard case let .int(intValue) = value else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Int but found \(value)"
            ))
        }
        return intValue
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        return Int8(try decode(Int.self))
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        return Int16(try decode(Int.self))
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        return Int32(try decode(Int.self))
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        return Int64(try decode(Int.self))
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        return UInt(try decode(Int.self))
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return UInt8(try decode(Int.self))
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return UInt16(try decode(Int.self))
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return UInt32(try decode(Int.self))
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return UInt64(try decode(Int.self))
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try T(from: decoder)
    }
}
