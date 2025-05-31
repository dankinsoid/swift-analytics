import Foundation

extension Analytics.ParametersValue {

  var jsonString: String {
    switch self {
    case let .string(value):
      return "\"\(value)\""
    case let .bool(value):
      return value ? "true" : "false"
    case let .int(value):
      return "\(value)"
    case let .double(value):
      return "\(value)"
    case let .array(values):
      let jsonArray = values.map { $0.jsonString }.joined(separator: ",")
      return "[\(jsonArray)]"
    case let .dictionary(dict):
      let jsonDict = dict.map { "\"\($0.key)\": \($0.value.jsonString)" }.joined(separator: ",")
      return "{\(jsonDict)}"
    }
  }
}
