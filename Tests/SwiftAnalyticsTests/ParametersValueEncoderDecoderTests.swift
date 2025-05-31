@testable import SwiftAnalytics
import XCTest

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
        let int32Value: Int32 = 2_147_483_647
        let int64Value: Int64 = 9_223_372_036_854_775_807
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
                case let .string(value):
                    try container.encode(value)
                case let .int(value):
                    try container.encode(value)
                case let .bool(value):
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
            Item(id: 3, name: "Cherry", price: 2.99),
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
                Tag(name: "coding", color: "blue"),
            ],
            comments: [
                Comment(author: "Alice", text: "Great post!", likes: 5),
                Comment(author: "Bob", text: "Thanks for sharing", likes: 3),
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

    // MARK: - Performance Tests

    func testPerformanceEncodeLargeArray() throws {
        let largeArray = Array(0 ..< 10000)

        measure {
            _ = try! encoder.encode(largeArray)
        }
    }

    func testPerformanceDecodeLargeArray() throws {
        let largeArray = Array(0 ..< 10000)
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

        let complexArray = (0 ..< 1000).map { i in
            ComplexItem(
                id: i,
                name: "Item \(i)",
                values: Array(0 ..< 10).map { Double($0) * 0.1 },
                metadata: ["key1": "value1", "key2": "value2", "key3": "value3"]
            )
        }

        measure {
            _ = try! encoder.encode(complexArray)
        }
    }

    // MARK: - Date Encoding/Decoding Tests

    func testEncodeDateStrategies() throws {
        let date = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01 00:00:00 UTC

        // Test secondsSince1970
        encoder.dateEncodingStrategy = .secondsSince1970
        decoder.dateDecodingStrategy = .secondsSince1970
        let encodedSeconds = try encoder.encode(date)
        let decodedSeconds = try decoder.decode(Date.self, from: encodedSeconds)
        XCTAssertEqual(date.timeIntervalSince1970, decodedSeconds.timeIntervalSince1970, accuracy: 0.001)

        // Test millisecondsSince1970
        encoder.dateEncodingStrategy = .millisecondsSince1970
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let encodedMillis = try encoder.encode(date)
        let decodedMillis = try decoder.decode(Date.self, from: encodedMillis)
        XCTAssertEqual(date.timeIntervalSince1970, decodedMillis.timeIntervalSince1970, accuracy: 0.001)

        // Test ISO8601
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        let encodedISO = try encoder.encode(date)
        let decodedISO = try decoder.decode(Date.self, from: encodedISO)
        XCTAssertEqual(date.timeIntervalSince1970, decodedISO.timeIntervalSince1970, accuracy: 1.0) // ISO8601 has second precision

        // Test formatted
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(formatter)
        decoder.dateDecodingStrategy = .formatted(formatter)
        let encodedFormatted = try encoder.encode(date)
        let decodedFormatted = try decoder.decode(Date.self, from: encodedFormatted)
        // Only compare the date part since time is lost in formatting
        let calendar = Calendar(identifier: .gregorian)
        let originalComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let decodedComponents = calendar.dateComponents([.year, .month, .day], from: decodedFormatted)
        XCTAssertEqual(originalComponents, decodedComponents)
    }

    // MARK: - Data Encoding/Decoding Tests

    func testEncodeDataStrategies() throws {
        let data = "Hello, World!".data(using: .utf8)!

        // Test base64
        encoder.dataEncodingStrategy = .base64
        decoder.dataDecodingStrategy = .base64
        let encodedBase64 = try encoder.encode(data)
        let decodedBase64 = try decoder.decode(Data.self, from: encodedBase64)
        XCTAssertEqual(data, decodedBase64)

        if case let .string(base64String) = encodedBase64 {
            XCTAssertEqual(base64String, data.base64EncodedString())
        } else {
            XCTFail("Expected string value for base64 encoded data")
        }
    }

    // MARK: - Key Strategy Tests

    func testKeyEncodingStrategies() throws {
        struct CamelCaseStruct: Codable, Equatable {
            let firstName: String
            let lastName: String
            let phoneNumber: String
        }

        let original = CamelCaseStruct(firstName: "John", lastName: "Doe", phoneNumber: "555-1234")

        // Test snake_case conversion
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(CamelCaseStruct.self, from: encoded)

        XCTAssertEqual(original, decoded)

        if case let .dictionary(dict) = encoded {
            XCTAssertNotNil(dict["first_name"])
            XCTAssertNotNil(dict["last_name"])
            XCTAssertNotNil(dict["phone_number"])
            XCTAssertNil(dict["firstName"])
            XCTAssertNil(dict["lastName"])
            XCTAssertNil(dict["phoneNumber"])
        } else {
            XCTFail("Expected dictionary value")
        }
    }

    // MARK: - URL Encoding/Decoding Tests

    func testEncodeDecodeURL() throws {
        let original = URL(string: "https://example.com/path?query=value")!
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(URL.self, from: encoded)

        XCTAssertEqual(original, decoded)
        if case let .string(urlString) = encoded {
            XCTAssertEqual(urlString, original.absoluteString)
        } else {
            XCTFail("Expected string value for URL")
        }
    }

    // MARK: - Decimal Encoding/Decoding Tests

    func testEncodeDecodeDecimal() throws {
        let original = Decimal(string: "123.456789")!
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Decimal.self, from: encoded)

        XCTAssertEqual(original, decoded)
        if case let .string(decimalString) = encoded {
            XCTAssertEqual(decimalString, original.description)
        } else {
            XCTFail("Expected string value for Decimal")
        }
    }

    func testDecodeDecimalFromNumber() throws {
        // Test decoding Decimal from int
        let intValue = Analytics.ParametersValue.int(42)
        let decodedFromInt = try decoder.decode(Decimal.self, from: intValue)
        XCTAssertEqual(decodedFromInt, Decimal(42))

        // Test decoding Decimal from double
        let doubleValue = Analytics.ParametersValue.double(3.14159)
        let decodedFromDouble = try decoder.decode(Decimal.self, from: doubleValue)
        XCTAssertEqual(decodedFromDouble, Decimal(3.14159))
    }

    // MARK: - Complex Structure with Special Types

    func testComplexStructureWithSpecialTypes() throws {
        struct ComplexStruct: Codable, Equatable {
            let id: Int
            let createdAt: Date
            let profileImage: Data
            let website: URL
            let price: Decimal
            let isActive: Bool
        }

        let original = ComplexStruct(
            id: 123,
            createdAt: Date(timeIntervalSince1970: 1_609_459_200),
            profileImage: "test image data".data(using: .utf8)!,
            website: URL(string: "https://example.com")!,
            price: Decimal(string: "99.99")!,
            isActive: true
        )

        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64

        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(ComplexStruct.self, from: encoded)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.createdAt.timeIntervalSince1970, decoded.createdAt.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(original.profileImage, decoded.profileImage)
        XCTAssertEqual(original.website, decoded.website)
        XCTAssertEqual(original.price, decoded.price)
        XCTAssertEqual(original.isActive, decoded.isActive)
    }
}
