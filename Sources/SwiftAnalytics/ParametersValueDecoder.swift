import Foundation

/// A decoder that converts `Analytics.ParametersValue` to any `Decodable` type.
public struct ParametersValueDecoder {

    /// The strategy to use for decoding `Date` values.
    public var dateDecodingStrategy: DateDecodingStrategy

    /// The strategy to use for decoding `Data` values.
    public var dataDecodingStrategy: DataDecodingStrategy

    /// The strategy to use for converting keys.
    public var keyDecodingStrategy: KeyDecodingStrategy

    public init(
        dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: DataDecodingStrategy = .base64,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    ) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
    }

    /// Decodes any `Decodable` type from `Analytics.ParametersValue`.
    public func decode<T: Decodable>(_ type: T.Type, from value: Analytics.ParametersValue) throws -> T {
        let decoder = _ParametersValueDecoder(
            value: value,
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )
        return try decoder.decode(type, from: value)
    }
}

public extension ParametersValueDecoder {

    typealias DateDecodingStrategy = JSONDecoder.DateDecodingStrategy
    typealias DataDecodingStrategy = JSONDecoder.DataDecodingStrategy
    typealias KeyDecodingStrategy = JSONDecoder.KeyDecodingStrategy
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
        _SingleValueDecodingContainer(decoder: self, value: value)
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

    @inlinable
    func stringValue(for key: Key) -> String {
        decoder.keyDecodingStrategy.decode(key, path: codingPath)
    }

    func contains(_ key: Key) -> Bool {
        dictionary[stringValue(for: key)] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
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
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
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
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
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
        try Float(decode(Double.self, forKey: key))
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
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
        try Int8(decode(Int.self, forKey: key))
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try Int16(decode(Int.self, forKey: key))
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try Int32(decode(Int.self, forKey: key))
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try Int64(decode(Int.self, forKey: key))
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try UInt(decode(Int.self, forKey: key))
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try UInt8(decode(Int.self, forKey: key))
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try UInt16(decode(Int.self, forKey: key))
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try UInt32(decode(Int.self, forKey: key))
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try UInt64(decode(Int.self, forKey: key))
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
            ))
        }

        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [key],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
        return try subDecoder.decode(type, from: value)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
            ))
        }
        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [key],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
        return try subDecoder.container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
            ))
        }
        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [key],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
        return try subDecoder.unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        decoder
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        guard let value = dictionary[stringValue(for: key)] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Key '\(stringValue(for: key))' not found"
            ))
        }
        return _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [key],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
    }
}

private struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] { decoder.codingPath }
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex = 0

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

    mutating func decode(_: Bool.Type) throws -> Bool {
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

    mutating func decode(_: String.Type) throws -> String {
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

    mutating func decode(_: Double.Type) throws -> Double {
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

    mutating func decode(_: Float.Type) throws -> Float {
        try Float(decode(Double.self))
    }

    mutating func decode(_: Int.Type) throws -> Int {
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

    mutating func decode(_: Int8.Type) throws -> Int8 {
        try Int8(decode(Int.self))
    }

    mutating func decode(_: Int16.Type) throws -> Int16 {
        try Int16(decode(Int.self))
    }

    mutating func decode(_: Int32.Type) throws -> Int32 {
        try Int32(decode(Int.self))
    }

    mutating func decode(_: Int64.Type) throws -> Int64 {
        try Int64(decode(Int.self))
    }

    mutating func decode(_: UInt.Type) throws -> UInt {
        try UInt(decode(Int.self))
    }

    mutating func decode(_: UInt8.Type) throws -> UInt8 {
        try UInt8(decode(Int.self))
    }

    mutating func decode(_: UInt16.Type) throws -> UInt16 {
        try UInt16(decode(Int.self))
    }

    mutating func decode(_: UInt32.Type) throws -> UInt32 {
        try UInt32(decode(Int.self))
    }

    mutating func decode(_: UInt64.Type) throws -> UInt64 {
        try UInt64(decode(Int.self))
    }

    mutating func decode<T>(_: T.Type) throws -> T where T: Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end"
            ))
        }
        let value = array[currentIndex]
        currentIndex += 1

        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [AnyCodingKey(intValue: array.count)],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
        return try subDecoder.decode(T.self, from: value)
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
        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [AnyCodingKey(intValue: array.count)],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
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
        let subDecoder = _ParametersValueDecoder(
            value: value,
            codingPath: codingPath + [AnyCodingKey(intValue: array.count)],
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
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
        return _ParametersValueDecoder(
            value: value,
            codingPath: codingPath,
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
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

    func decode(_: Bool.Type) throws -> Bool {
        guard case let .bool(boolValue) = value else {
            throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Bool but found \(value)"
            ))
        }
        return boolValue
    }

    func decode(_: String.Type) throws -> String {
        guard case let .string(stringValue) = value else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected String but found \(value)"
            ))
        }
        return stringValue
    }

    func decode(_: Double.Type) throws -> Double {
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

    func decode(_: Float.Type) throws -> Float {
        try Float(decode(Double.self))
    }

    func decode(_: Int.Type) throws -> Int {
        guard case let .int(intValue) = value else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected Int but found \(value)"
            ))
        }
        return intValue
    }

    func decode(_: Int8.Type) throws -> Int8 {
        try Int8(decode(Int.self))
    }

    func decode(_: Int16.Type) throws -> Int16 {
        try Int16(decode(Int.self))
    }

    func decode(_: Int32.Type) throws -> Int32 {
        try Int32(decode(Int.self))
    }

    func decode(_: Int64.Type) throws -> Int64 {
        try Int64(decode(Int.self))
    }

    func decode(_: UInt.Type) throws -> UInt {
        try UInt(decode(Int.self))
    }

    func decode(_: UInt8.Type) throws -> UInt8 {
        try UInt8(decode(Int.self))
    }

    func decode(_: UInt16.Type) throws -> UInt16 {
        try UInt16(decode(Int.self))
    }

    func decode(_: UInt32.Type) throws -> UInt32 {
        try UInt32(decode(Int.self))
    }

    func decode(_: UInt64.Type) throws -> UInt64 {
        try UInt64(decode(Int.self))
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try decoder.decode(type, from: value)
    }
}

// MARK: - Helper Extensions

private extension _ParametersValueDecoder {

    func decode<T: Decodable>(_ type: T.Type, from value: Analytics.ParametersValue) throws -> T {
        // Handle special types
        if type == Date.self {
            return try decodeDate(from: value) as! T
        } else if type == Data.self {
            return try decodeData(from: value) as! T
        } else if type == URL.self {
            return try decodeURL(from: value) as! T
        } else if type == Decimal.self {
            return try decodeDecimal(from: value) as! T
        } else if let result = value as? T {
            return result
        } else {
            return try T(from: self)
        }
    }

    static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

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
            case let .double(timeInterval):
                return Date(timeIntervalSince1970: timeInterval)
            case let .int(timeInterval):
                return Date(timeIntervalSince1970: Double(timeInterval))
            default:
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected number for Date decoding but found \(value)"
                ))
            }

        case .millisecondsSince1970:
            switch value {
            case let .double(timeInterval):
                return Date(timeIntervalSince1970: timeInterval / 1000.0)
            case let .int(timeInterval):
                return Date(timeIntervalSince1970: Double(timeInterval) / 1000.0)
            default:
                throw DecodingError.typeMismatch(Date.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected number for Date decoding but found \(value)"
                ))
            }

        case .iso8601:
            guard case let .string(string) = value else {
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
                guard let date = Self.iso8601DateFormatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Expected date string to be ISO8601-formatted."
                    ))
                }
                return date
            }

        case let .formatted(formatter):
            guard case let .string(string) = value else {
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

        case let .custom(closure):
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
            guard case let .string(string) = value else {
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

        case let .custom(closure):
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
        guard case let .string(string) = value else {
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
        case let .string(string):
            guard let decimal = Decimal(string: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Invalid Decimal string."
                ))
            }
            return decimal
        case let .int(int):
            return Decimal(int)
        case let .double(double):
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

    func decode(_ key: CodingKey, path: [CodingKey]) -> String {
        switch self {
        case .useDefaultKeys:
            return key.stringValue

        case .convertFromSnakeCase:
            return ParametersValueEncoder.KeyEncodingStrategy.convertToSnakeCase.encode(key, codingPath: path)

        case let .custom(closure):
            return closure(path + [key]).stringValue
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
