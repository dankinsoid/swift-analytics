import Foundation

/// A type-erased `CodingKey` that can wrap any `CodingKey` type.
struct AnyCodingKey: CodingKey {

  /// The string value of the key.
  var stringValue: String

  /// The integer value of the key, if applicable.
  var intValue: Int?

  /// Initializes with a string value.
  init(stringValue: String) {
    self.stringValue = stringValue
    intValue = nil
  }

  /// Initializes with an integer value.
  init(intValue: Int) {
    stringValue = String(intValue)
    self.intValue = intValue
  }
}
