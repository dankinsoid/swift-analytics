import Foundation

/// A decoder that converts `Analytics.ParametersValue` to any `Decodable` type.
public struct ParametersValueDecoder {
    
    /// The strategy to use for decoding `Date` values.
    public var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    
    /// The strategy to use for decoding `Data` values.
    public var dataDecodingStrategy: DataDecodingStrategy = .base64
    
    /// The strategy to use for converting keys.
    public var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    
    public init() {}
    
    /// Decodes any `Decodable` type from `Analytics.ParametersValue`.
    public func decode<T: Decodable>(_ type: T.Type, from value: Analytics.ParametersValue) throws -> T {
        let decoder = _ParametersValueDecoder(
            value: value,
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )
        return try T(from: decoder)
    }
}

public extension ParametersValueDecoder {
    
    /// The strategy to use for decoding `Date` values.
    enum DateDecodingStrategy {
        /// Defer to `Date` for choosing a decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((Decoder) throws -> Date)
    }
    
    /// The strategy to use for decoding `Data` values.
    enum DataDecodingStrategy {
        /// Defer to `Data` for choosing a decoding.
        case deferredToData
        
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((Decoder) throws -> Data)
    }
    
    /// The strategy to use for automatically changing the value of keys before decoding.
    enum KeyDecodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys
        
        /// Convert from "snake_case" to "camelCase".
        case convertFromSnakeCase
        
        /// Provide a custom conversion from the key in the encoded JSON to the key in the decoded type.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
    }
}

private final class _ParametersValueDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    
    private let value: Analytics.ParametersValue
    let dateDecodingStrategy: ParametersValueDecoder.DateDecodingStrategy
    let dataDecodingStrategy: ParametersValueDecoder.DataDecodingStrategy
    let keyDecodingStrategy: ParametersValueDecoder.KeyDecodingStrategy
    
    init(
        value: Analytics.ParametersValue,
        codingPath: [CodingKey] = [],
        dateDecodingStrategy: ParametersValueDecoder.DateDecodingStrategy,
        dataDecodingStrategy: ParametersValueDecoder.DataDecodingStrategy,
        keyDecodingStrategy: ParametersValueDecoder.KeyDecodingStrategy
    ) {
        self.value = value
        self.codingPath = codingPath
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
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
        let decodedKey = decoder.keyDecodingStrategy.decode(key, from: dictionary.keys)
        guard let value = dictionary[decodedKey] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(key.stringValue)' not found"
            ))
        }
        
        // Handle special types
        if type == Date.self {
            return try decoder.decodeDate(from: value) as! T
        } else if type == Data.self {
            return try decoder.decodeData(from: value) as! T
        } else if type == URL.self {
            return try decoder.decodeURL(from: value) as! T
        } else if type == Decimal.self {
            return try decoder.decodeDecimal(from: value) as! T
        } else {
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath + [key],
                dateDecodingStrategy: decoder.dateDecodingStrategy,
                dataDecodingStrategy: decoder.dataDecodingStrategy,
                keyDecodingStrategy: decoder.keyDecodingStrategy
            )
            return try T(from: subDecoder)
        }
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
        
        // Handle special types
        if type == Date.self {
            return try decoder.decodeDate(from: value) as! T
        } else if type == Data.self {
            return try decoder.decodeData(from: value) as! T
        } else if type == URL.self {
            return try decoder.decodeURL(from: value) as! T
        } else if type == Decimal.self {
            return try decoder.decodeDecimal(from: value) as! T
        } else {
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath,
                dateDecodingStrategy: decoder.dateDecodingStrategy,
                dataDecodingStrategy: decoder.dataDecodingStrategy,
                keyDecodingStrategy: decoder.keyDecodingStrategy
            )
            return try T(from: subDecoder)
        }
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
        // Handle special types
        if type == Date.self {
            return try decoder.decodeDate(from: value) as! T
        } else if type == Data.self {
            return try decoder.decodeData(from: value) as! T
        } else if type == URL.self {
            return try decoder.decodeURL(from: value) as! T
        } else if type == Decimal.self {
            return try decoder.decodeDecimal(from: value) as! T
        } else {
            return try T(from: decoder)
        }
    }
}

// MARK: - Helper Extensions

private extension _ParametersValueDecoder {
    
    func decodeDate(from value: Analytics.ParametersValue) throws -> Date {
        switch dateDecodingStrategy {
        case .deferredToDate:
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath,
                dateDecodingStrategy: dateDecodingStrategy,
                dataDecodingStrategy: dataDecodingStrategy,
                keyDecodingStrategy: keyDecodingStrategy
            )
            return try Date(from: subDecoder)
            
        case .secondsSince1970:
            switch value {
            case .double(let timeInterval):
                return Date(timeIntervalSince1970: timeInterval)
            case .int(let timeInterval):
                return Date(timeIntervalSince1970: Double(timeInterval))
            default:
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected number for Date decoding but found \(value)"
                ))
            }
            
        case .millisecondsSince1970:
            switch value {
            case .double(let timeInterval):
                return Date(timeIntervalSince1970: timeInterval / 1000.0)
            case .int(let timeInterval):
                return Date(timeIntervalSince1970: Double(timeInterval) / 1000.0)
            default:
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected number for Date decoding but found \(value)"
                ))
            }
            
        case .iso8601:
            guard case .string(let string) = value else {
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected string for ISO8601 Date decoding but found \(value)"
                ))
            }
            
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                guard let date = ISO8601DateFormatter().date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Expected date string to be ISO8601-formatted."
                    ))
                }
                return date
            } else {
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                guard let date = formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Expected date string to be ISO8601-formatted."
                    ))
                }
                return date
            }
            
        case .formatted(let formatter):
            guard case .string(let string) = value else {
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected string for formatted Date decoding but found \(value)"
                ))
            }
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Date string does not match format expected by formatter."
                ))
            }
            return date
            
        case .custom(let closure):
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath,
                dateDecodingStrategy: dateDecodingStrategy,
                dataDecodingStrategy: dataDecodingStrategy,
                keyDecodingStrategy: keyDecodingStrategy
            )
            return try closure(subDecoder)
        }
    }
    
    func decodeData(from value: Analytics.ParametersValue) throws -> Data {
        switch dataDecodingStrategy {
        case .deferredToData:
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath,
                dateDecodingStrategy: dateDecodingStrategy,
                dataDecodingStrategy: dataDecodingStrategy,
                keyDecodingStrategy: keyDecodingStrategy
            )
            return try Data(from: subDecoder)
            
        case .base64:
            guard case .string(let string) = value else {
                throw DecodingError.typeMismatch(Data.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected string for base64 Data decoding but found \(value)"
                ))
            }
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Encountered Data is not valid Base64."
                ))
            }
            return data
            
        case .custom(let closure):
            let subDecoder = _ParametersValueDecoder(
                value: value,
                codingPath: codingPath,
                dateDecodingStrategy: dateDecodingStrategy,
                dataDecodingStrategy: dataDecodingStrategy,
                keyDecodingStrategy: keyDecodingStrategy
            )
            return try closure(subDecoder)
        }
    }
    
    func decodeURL(from value: Analytics.ParametersValue) throws -> URL {
        guard case .string(let string) = value else {
            throw DecodingError.typeMismatch(URL.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected string for URL decoding but found \(value)"
            ))
        }
        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Invalid URL string."
            ))
        }
        return url
    }
    
    func decodeDecimal(from value: Analytics.ParametersValue) throws -> Decimal {
        switch value {
        case .string(let string):
            guard let decimal = Decimal(string: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Invalid Decimal string."
                ))
            }
            return decimal
        case .int(let int):
            return Decimal(int)
        case .double(let double):
            return Decimal(double)
        default:
            throw DecodingError.typeMismatch(Decimal.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected string or number for Decimal decoding but found \(value)"
            ))
        }
    }
}

private extension ParametersValueDecoder.KeyDecodingStrategy {
    
    func decode<Key: CodingKey>(_ key: Key, from availableKeys: Dictionary<String, Analytics.ParametersValue>.Keys) -> String {
        switch self {
        case .useDefaultKeys:
            return key.stringValue
            
        case .convertFromSnakeCase:
            let convertedKey = convertFromSnakeCase(key.stringValue)
            // Try the converted key first, fall back to original if not found
            return availableKeys.contains(convertedKey) ? convertedKey : key.stringValue
            
        case .custom(let closure):
            return closure([key]).stringValue
        }
    }
    
    private func convertFromSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }
        guard stringKey.contains("_") else { return stringKey }
        
        let components = stringKey.components(separatedBy: "_")
        guard components.count > 1 else { return stringKey }
        
        let first = components[0]
        let rest = components[1...].map { $0.capitalized }
        return ([first] + rest).joined()
    }
}
