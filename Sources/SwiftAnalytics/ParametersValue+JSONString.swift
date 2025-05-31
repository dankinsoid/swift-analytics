import Foundation

public extension Analytics.ParametersValue {

  /// Returns a JSON string representation of the parameters value.
  var jsonString: String {
    switch self {
    case let .string(value):
      return "\"\(value.escapedForJSON)\""
    case let .bool(value):
      return value ? "true" : "false"
    case let .int(value):
      return "\(value)"
    case let .double(value):
      if value.isFinite {
        return "\(value)"
      } else if value.isInfinite {
        return value > 0 ? "\"Infinity\"" : "\"-Infinity\""
      } else {
        return "\"NaN\""
      }
    case let .array(values):
      let jsonArray = values.map { $0.jsonString }.joined(separator: ",")
      return "[\(jsonArray)]"
    case let .dictionary(dict):
      let sortedKeys = dict.keys.sorted()
      let jsonDict = sortedKeys.map { key in
        "\"\(key.escapedForJSON)\": \(dict[key]!.jsonString)"
      }.joined(separator: ",")
      return "{\(jsonDict)}"
    }
  }

  /// Returns a pretty-printed JSON string representation of the parameters value.
  var prettyJSONString: String {
    _prettyJSONString(indent: 0)
  }

  private func _prettyJSONString(indent: Int) -> String {
    let indentString = String(repeating: "  ", count: indent)
    let nextIndentString = String(repeating: "  ", count: indent + 1)
    
    switch self {
    case let .string(value):
      return "\"\(value.escapedForJSON)\""
    case let .bool(value):
      return value ? "true" : "false"
    case let .int(value):
      return "\(value)"
    case let .double(value):
      if value.isFinite {
        return "\(value)"
      } else if value.isInfinite {
        return value > 0 ? "\"Infinity\"" : "\"-Infinity\""
      } else {
        return "\"NaN\""
      }
    case let .array(values):
      if values.isEmpty {
        return "[]"
      }
      let jsonArray = values.map { value in
        "\(nextIndentString)\(value._prettyJSONString(indent: indent + 1))"
      }.joined(separator: ",\n")
      return "[\n\(jsonArray)\n\(indentString)]"
    case let .dictionary(dict):
      if dict.isEmpty {
        return "{}"
      }
      let sortedKeys = dict.keys.sorted()
      let jsonDict = sortedKeys.map { key in
        "\(nextIndentString)\"\(key.escapedForJSON)\": \(dict[key]!._prettyJSONString(indent: indent + 1))"
      }.joined(separator: ",\n")
      return "{\n\(jsonDict)\n\(indentString)}"
    }
  }
}

private extension String {

  var escapedForJSON: String {
    var result = ""
    for char in self {
      switch char {
      case "\"":
        result += "\\\""
      case "\\":
        result += "\\\\"
      case "\n":
        result += "\\n"
      case "\r":
        result += "\\r"
      case "\t":
        result += "\\t"
      case "\u{08}":
        result += "\\b"
      case "\u{0C}":
        result += "\\f"
      default:
        if char.isASCII, char.asciiValue! < 32 {
          result += String(format: "\\u%04x", char.asciiValue!)
        } else {
          result += String(char)
        }
      }
    }
    return result
  }
}
