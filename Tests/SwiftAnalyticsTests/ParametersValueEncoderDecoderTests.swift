import XCTest
@testable import SwiftAnalytics

final class ParametersValueEncoderDecoderTests: XCTestCase {
    
    var encoder: ParametersValueEncoder!
    var decoder: ParametersValueDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = ParametersValueEncoder()
        decoder = ParametersValueDecoder()
    }
    
    override func tearDown() {
        encoder = nil
        decoder = nil
        super.tearDown()
    }
    
    // MARK: - Basic Types Tests
    
    func testEncodeDecodeString() throws {
        let original = "Hello, World!"
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(String.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .string(value) = encoded {
            XCTAssertEqual(value, original)
        } else {
            XCTFail("Expected string value")
        }
    }
    
    func testEncodeDecodeInt() throws {
        let original = 42
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Int.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .int(value) = encoded {
            XCTAssertEqual(value, original)
        } else {
            XCTFail("Expected int value")
        }
    }
    
    func testEncodeDecodeDouble() throws {
        let original = 3.14159
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Double.self, from: encoded)
        
        XCTAssertEqual(original, decoded, accuracy: 0.000001)
        if case let .double(value) = encoded {
            XCTAssertEqual(value, original, accuracy: 0.000001)
        } else {
            XCTFail("Expected double value")
        }
    }
    
    func testEncodeDecodeFloat() throws {
        let original: Float = 2.718
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Float.self, from: encoded)
        
        XCTAssertEqual(original, decoded, accuracy: 0.0001)
        if case let .double(value) = encoded {
            XCTAssertEqual(Double(original), value, accuracy: 0.000001)
        } else {
            XCTFail("Expected double value (Float encoded as Double)")
        }
    }
    
    func testEncodeDecodeBool() throws {
        let originalTrue = true
        let originalFalse = false
        
        let encodedTrue = try encoder.encode(originalTrue)
        let encodedFalse = try encoder.encode(originalFalse)
        
        let decodedTrue = try decoder.decode(Bool.self, from: encodedTrue)
        let decodedFalse = try decoder.decode(Bool.self, from: encodedFalse)
        
        XCTAssertEqual(originalTrue, decodedTrue)
        XCTAssertEqual(originalFalse, decodedFalse)
    }
    
    // MARK: - Integer Type Conversion Tests
    
    func testEncodeDecodeIntegerTypes() throws {
        let int8Value: Int8 = 127
        let int16Value: Int16 = 32767
        let int32Value: Int32 = 2147483647
        let int64Value: Int64 = 9223372036854775807
        let uintValue: UInt = 42
        
        // All integer types should encode to .int and decode back correctly
        let encodedInt8 = try encoder.encode(int8Value)
        let encodedInt16 = try encoder.encode(int16Value)
        let encodedInt32 = try encoder.encode(int32Value)
        let encodedInt64 = try encoder.encode(int64Value)
        let encodedUInt = try encoder.encode(uintValue)
        
        let decodedInt8 = try decoder.decode(Int8.self, from: encodedInt8)
        let decodedInt16 = try decoder.decode(Int16.self, from: encodedInt16)
        let decodedInt32 = try decoder.decode(Int32.self, from: encodedInt32)
        let decodedInt64 = try decoder.decode(Int64.self, from: encodedInt64)
        let decodedUInt = try decoder.decode(UInt.self, from: encodedUInt)
        
        XCTAssertEqual(int8Value, decodedInt8)
        XCTAssertEqual(int16Value, decodedInt16)
        XCTAssertEqual(int32Value, decodedInt32)
        XCTAssertEqual(int64Value, decodedInt64)
        XCTAssertEqual(uintValue, decodedUInt)
    }
    
    // MARK: - Array Tests
    
    func testEncodeDecodeSimpleArray() throws {
        let original = [1, 2, 3, 4, 5]
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([Int].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .array(values) = encoded {
            XCTAssertEqual(values.count, 5)
        } else {
            XCTFail("Expected array value")
        }
    }
    
    func testEncodeDecodeStringArray() throws {
        let original = ["apple", "banana", "cherry"]
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([String].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testEncodeDecodeNestedArrays() throws {
        let original = [[1, 2], [3, 4], [5, 6]]
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([[Int]].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .array(outerArray) = encoded {
            XCTAssertEqual(outerArray.count, 3)
            for element in outerArray {
                if case let .array(innerArray) = element {
                    XCTAssertEqual(innerArray.count, 2)
                } else {
                    XCTFail("Expected nested array")
                }
            }
        } else {
            XCTFail("Expected array value")
        }
    }
    
    func testEncodeDecodeDeeplyNestedArrays() throws {
        let original = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([[[Int]]].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testEncodeDecodeMixedTypeArray() throws {
        struct MixedArray: Codable, Equatable {
            let values: [MixedValue]
        }
        
        enum MixedValue: Codable, Equatable {
            case string(String)
            case int(Int)
            case bool(Bool)
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .int(let value):
                    try container.encode(value)
                case .bool(let value):
                    try container.encode(value)
                }
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else if let intValue = try? container.decode(Int.self) {
                    self = .int(intValue)
                } else if let boolValue = try? container.decode(Bool.self) {
                    self = .bool(boolValue)
                } else {
                    throw DecodingError.typeMismatch(MixedValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode MixedValue"))
                }
            }
        }
        
        let original = MixedArray(values: [.string("hello"), .int(42), .bool(true)])
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(MixedArray.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    // MARK: - Dictionary/Object Tests
    
    func testEncodeDecodeSimpleStruct() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
            let isActive: Bool
        }
        
        let original = Person(name: "Alice", age: 30, isActive: true)
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Person.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .dictionary(dict) = encoded {
            XCTAssertEqual(dict.count, 3)
            XCTAssertEqual(dict["name"], .string("Alice"))
            XCTAssertEqual(dict["age"], .int(30))
            XCTAssertEqual(dict["isActive"], .bool(true))
        } else {
            XCTFail("Expected dictionary value")
        }
    }
    
    func testEncodeDecodeNestedStruct() throws {
        struct Address: Codable, Equatable {
            let street: String
            let city: String
            let zipCode: String
        }
        
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
            let address: Address
        }
        
        let original = Person(
            name: "Bob",
            age: 25,
            address: Address(street: "123 Main St", city: "Anytown", zipCode: "12345")
        )
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Person.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .dictionary(personDict) = encoded {
            if case let .dictionary(addressDict) = personDict["address"] {
                XCTAssertEqual(addressDict["street"], .string("123 Main St"))
                XCTAssertEqual(addressDict["city"], .string("Anytown"))
                XCTAssertEqual(addressDict["zipCode"], .string("12345"))
            } else {
                XCTFail("Expected nested dictionary for address")
            }
        } else {
            XCTFail("Expected dictionary value")
        }
    }
    
    func testEncodeDecodeDeeplyNestedStructs() throws {
        struct Country: Codable, Equatable {
            let name: String
            let code: String
        }
        
        struct Address: Codable, Equatable {
            let street: String
            let city: String
            let country: Country
        }
        
        struct Person: Codable, Equatable {
            let name: String
            let address: Address
        }
        
        let original = Person(
            name: "Charlie",
            address: Address(
                street: "456 Oak Ave",
                city: "Somewhere",
                country: Country(name: "United States", code: "US")
            )
        )
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Person.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    // MARK: - Complex Nested Structures
    
    func testEncodeDecodeArrayOfStructs() throws {
        struct Item: Codable, Equatable {
            let id: Int
            let name: String
            let price: Double
        }
        
        let original = [
            Item(id: 1, name: "Apple", price: 1.99),
            Item(id: 2, name: "Banana", price: 0.99),
            Item(id: 3, name: "Cherry", price: 2.99)
        ]
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([Item].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testEncodeDecodeStructWithArrays() throws {
        struct Team: Codable, Equatable {
            let name: String
            let members: [String]
            let scores: [Int]
        }
        
        let original = Team(
            name: "Alpha Team",
            members: ["Alice", "Bob", "Charlie"],
            scores: [95, 87, 92]
        )
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Team.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testEncodeDecodeComplexNestedStructure() throws {
        struct Tag: Codable, Equatable {
            let name: String
            let color: String
        }
        
        struct Comment: Codable, Equatable {
            let author: String
            let text: String
            let likes: Int
        }
        
        struct Post: Codable, Equatable {
            let id: Int
            let title: String
            let content: String
            let tags: [Tag]
            let comments: [Comment]
            let metadata: [String: String]
        }
        
        let original = Post(
            id: 1,
            title: "Hello World",
            content: "This is a test post",
            tags: [
                Tag(name: "swift", color: "orange"),
                Tag(name: "coding", color: "blue")
            ],
            comments: [
                Comment(author: "Alice", text: "Great post!", likes: 5),
                Comment(author: "Bob", text: "Thanks for sharing", likes: 3)
            ],
            metadata: ["category": "tutorial", "difficulty": "beginner"]
        )
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Post.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    // MARK: - Edge Cases
    
    func testEncodeDecodeEmptyArray() throws {
        let original: [Int] = []
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode([Int].self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .array(values) = encoded {
            XCTAssertTrue(values.isEmpty)
        } else {
            XCTFail("Expected empty array")
        }
    }
    
    func testEncodeDecodeEmptyStruct() throws {
        struct Empty: Codable, Equatable {}
        
        let original = Empty()
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Empty.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
        if case let .dictionary(dict) = encoded {
            XCTAssertTrue(dict.isEmpty)
        } else {
            XCTFail("Expected empty dictionary")
        }
    }
    
    func testEncodeDecodeOptionalValues() throws {
        struct OptionalStruct: Codable, Equatable {
            let required: String
            let optional: String?
        }
        
        let withOptional = OptionalStruct(required: "test", optional: "value")
        let withoutOptional = OptionalStruct(required: "test", optional: nil)
        
        let encodedWith = try encoder.encode(withOptional)
        let encodedWithout = try encoder.encode(withoutOptional)
        
        let decodedWith = try decoder.decode(OptionalStruct.self, from: encodedWith)
        let decodedWithout = try decoder.decode(OptionalStruct.self, from: encodedWithout)
        
        XCTAssertEqual(withOptional, decodedWith)
        XCTAssertEqual(withoutOptional, decodedWithout)
        
        // Check that nil values are not included in the encoded dictionary
        if case let .dictionary(dict) = encodedWithout {
            XCTAssertNil(dict["optional"])
            XCTAssertEqual(dict.count, 1) // Only "required" should be present
        } else {
            XCTFail("Expected dictionary")
        }
    }
    
    func testEncodeDecodeSpecialFloatValues() throws {
        let infinity = Double.infinity
        let negativeInfinity = -Double.infinity
        let nan = Double.nan
        
        let encodedInfinity = try encoder.encode(infinity)
        let encodedNegativeInfinity = try encoder.encode(negativeInfinity)
        let encodedNaN = try encoder.encode(nan)
        
        let decodedInfinity = try decoder.decode(Double.self, from: encodedInfinity)
        let decodedNegativeInfinity = try decoder.decode(Double.self, from: encodedNegativeInfinity)
        let decodedNaN = try decoder.decode(Double.self, from: encodedNaN)
        
        XCTAssertEqual(infinity, decodedInfinity)
        XCTAssertEqual(negativeInfinity, decodedNegativeInfinity)
        XCTAssertTrue(decodedNaN.isNaN)
    }
    
    func testEncodeDecodeUnicodeStrings() throws {
        let original = "Hello 🌍! Café naïve résumé 中文 العربية"
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(String.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testEncodeDecodeVeryLargeNumbers() throws {
        let largeInt = Int.max
        let smallInt = Int.min
        let largeDouble = Double.greatestFiniteMagnitude
        let smallDouble = -Double.greatestFiniteMagnitude
        
        let encodedLargeInt = try encoder.encode(largeInt)
        let encodedSmallInt = try encoder.encode(smallInt)
        let encodedLargeDouble = try encoder.encode(largeDouble)
        let encodedSmallDouble = try encoder.encode(smallDouble)
        
        let decodedLargeInt = try decoder.decode(Int.self, from: encodedLargeInt)
        let decodedSmallInt = try decoder.decode(Int.self, from: encodedSmallInt)
        let decodedLargeDouble = try decoder.decode(Double.self, from: encodedLargeDouble)
        let decodedSmallDouble = try decoder.decode(Double.self, from: encodedSmallDouble)
        
        XCTAssertEqual(largeInt, decodedLargeInt)
        XCTAssertEqual(smallInt, decodedSmallInt)
        XCTAssertEqual(largeDouble, decodedLargeDouble)
        XCTAssertEqual(smallDouble, decodedSmallDouble)
    }
    
    // MARK: - Error Cases
    
    func testDecodeTypeMismatch() throws {
        let stringValue = Analytics.ParametersValue.string("not a number")
        
        XCTAssertThrowsError(try decoder.decode(Int.self, from: stringValue)) { error in
            XCTAssertTrue(error is DecodingError)
            if case DecodingError.typeMismatch = error {
                // Expected
            } else {
                XCTFail("Expected typeMismatch error")
            }
        }
    }
    
    func testDecodeKeyNotFound() throws {
        let incompleteDict = Analytics.ParametersValue.dictionary(["name": .string("Alice")])
        
        struct Person: Codable {
            let name: String
            let age: Int // This key is missing
        }
        
        XCTAssertThrowsError(try decoder.decode(Person.self, from: incompleteDict)) { error in
            XCTAssertTrue(error is DecodingError)
            if case DecodingError.keyNotFound = error {
                // Expected
            } else {
                XCTFail("Expected keyNotFound error")
            }
        }
    }
    
    func testDecodeArrayIndexOutOfBounds() throws {
        let shortArray = Analytics.ParametersValue.array([.int(1), .int(2)])
        
        // Try to decode as a 3-element array
        XCTAssertThrowsError(try decoder.decode([Int].self, from: shortArray)) { error in
            // This should succeed since we're decoding the exact array
        }
        
        // But if we manually try to access beyond bounds in unkeyed container, it should fail
        let decoder = _ParametersValueDecoder(value: shortArray)
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self) // 1
        _ = try container.decode(Int.self) // 2
        
        XCTAssertThrowsError(try container.decode(Int.self)) { error in
            XCTAssertTrue(error is DecodingError)
            if case DecodingError.valueNotFound = error {
                // Expected
            } else {
                XCTFail("Expected valueNotFound error")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceEncodeLargeArray() throws {
        let largeArray = Array(0..<10000)
        
        measure {
            _ = try! encoder.encode(largeArray)
        }
    }
    
    func testPerformanceDecodeLargeArray() throws {
        let largeArray = Array(0..<10000)
        let encoded = try encoder.encode(largeArray)
        
        measure {
            _ = try! decoder.decode([Int].self, from: encoded)
        }
    }
    
    func testPerformanceEncodeComplexStructure() throws {
        struct ComplexItem: Codable {
            let id: Int
            let name: String
            let values: [Double]
            let metadata: [String: String]
        }
        
        let complexArray = (0..<1000).map { i in
            ComplexItem(
                id: i,
                name: "Item \(i)",
                values: Array(0..<10).map { Double($0) * 0.1 },
                metadata: ["key1": "value1", "key2": "value2", "key3": "value3"]
            )
        }
        
        measure {
            _ = try! encoder.encode(complexArray)
        }
    }
}

// Helper to access private decoder for testing
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
