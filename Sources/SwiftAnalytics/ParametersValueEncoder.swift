import Foundation

/// An encoder that converts any `Encodable` type to `Analytics.ParametersValue`.
public struct ParametersValueEncoder {

    /// The strategy to use for encoding `Date` values.
    public var dateEncodingStrategy: DateEncodingStrategy

    /// The strategy to use for encoding `Data` values.
    public var dataEncodingStrategy: DataEncodingStrategy

    /// The strategy to use for converting keys.
    public var keyEncodingStrategy: KeyEncodingStrategy

    public init(
        dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: DataEncodingStrategy = .base64,
        keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
    ) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
    }

    /// Encodes any `Encodable` value to `Analytics.ParametersValue`.
    public func encode<T: Encodable>(_ value: T) throws -> Analytics.ParametersValue {
        let encoder = _ParametersValueEncoder(
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy
        )
        try encoder.encode(value)
        return encoder.result
    }
}

public extension ParametersValueEncoder {

    typealias DateEncodingStrategy = JSONEncoder.DateEncodingStrategy
    typealias DataEncodingStrategy = JSONEncoder.DataEncodingStrategy
    typealias KeyEncodingStrategy = JSONEncoder.KeyEncodingStrategy
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

    @inlinable
    func stringValue(for key: Key) -> String {
        encoder.keyEncodingStrategy.encode(key, codingPath: codingPath)
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        storage[stringValue(for: key)] = .bool(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        storage[stringValue(for: key)] = .string(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        storage[stringValue(for: key)] = .double(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        storage[stringValue(for: key)] = .double(Double(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(value)
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        storage[stringValue(for: key)] = .int(Int(value))
        encoder.result = .dictionary(storage)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        let encodedKey = encoder.keyEncodingStrategy.encode(key, codingPath: codingPath)
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [key]
        try subEncoder.encode(value)
        storage[encodedKey] = subEncoder.result
        encoder.result = .dictionary(storage)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [key]
        let container = _KeyedEncodingContainer<NestedKey>(encoder: subEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [key]
        return _UnkeyedEncodingContainer(encoder: subEncoder)
    }

    mutating func superEncoder() -> Encoder {
        encoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
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
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [AnyCodingKey(intValue: count)]
        try subEncoder.encode(value)
        storage.append(subEncoder.result)
        encoder.result = .array(storage)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [AnyCodingKey(intValue: count)]
        let container = _KeyedEncodingContainer<NestedKey>(encoder: subEncoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let subEncoder = _ParametersValueEncoder(
            dateEncodingStrategy: encoder.dateEncodingStrategy,
            dataEncodingStrategy: encoder.dataEncodingStrategy,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        subEncoder.codingPath = codingPath + [AnyCodingKey(intValue: count)]
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
        try encoder.encode(value)
    }
}

// MARK: - Helper Extensions

private extension _ParametersValueEncoder {

    func encode<T: Encodable>(_ value: T) throws {
        // Handle special types
        if let date = value as? Date {
            result = try encodeDate(date)
        } else if let data = value as? Data {
            result = try encodeData(data)
        } else if let url = value as? URL {
            result = .string(url.absoluteString)
        } else if let decimal = value as? Decimal {
            result = .string(decimal.description)
        } else {
            try value.encode(to: self)
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

    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    static let iso8601DateFormatterWithOptions: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

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
                return .string(Self.iso8601DateFormatterWithOptions.string(from: date))
            } else {
                return .string(Self.iso8601DateFormatter.string(from: date))
            }

        case let .formatted(formatter):
            return .string(formatter.string(from: date))

        case let .custom(closure):
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

        case let .custom(closure):
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

extension ParametersValueEncoder.KeyEncodingStrategy {

    func encode<Key: CodingKey>(_ key: Key, codingPath: [CodingKey]) -> String {
        switch self {
        case .useDefaultKeys:
            return key.stringValue

        case .convertToSnakeCase:
            return convertToSnakeCase(key.stringValue)

        case let .custom(closure):
            return closure(codingPath + [key]).stringValue
        }
    }

    private func convertToSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }

        var result = ""
        var previousCharacterWasUppercase = false

        for (index, character) in stringKey.enumerated() {
            if character.isUppercase {
                if index > 0, !previousCharacterWasUppercase {
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
