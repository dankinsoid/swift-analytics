# SwiftAnalytics
SwiftAnalytics is an API package which tries to establish a common API the ecosystem can use.
To make analytics really work for real-world workloads, we need SwiftAnalytics-compatible analytics backends which send events to Firebase, Amplitude, DataDog, etc.

## Getting Started

### Adding the dependency
To depend on the analytics API package, you need to declare your dependency in your Package.swift:
```swift
.package(url: "https://github.com/dankinsoid/swift-analytics.git", from: "1.9.0"),
```
and to your application/library target, add "SwiftAnalytics" to your dependencies, e.g. like this:
```swift
.target(name: "BestExampleApp", dependencies: [
    .product(name: "SwiftAnalytics", package: "swift-analytics")
],
```
### Let's send events
1. let's import the SwiftAnalytics API package
```swift
import SwiftAnalytics
```

2. we need to bootstrap the analytics system with a default analytics handler, which is usually a custom implementation of `AnalyticsHandler` protocol. For example you can use FirebaseAnalyticsHandler from the [swift-firebase-tools](https://github.com/dankinsoid/swift-firebase-tools) package, or you can implement your own analytics handler, it's a very simple protocol.

```swift
AnalyticsSystem.bootstrap(FirebaseAnalyticsHandler())
```

3. we need to create a Analytics
```swift
let analytics = Analytics()
```

4. we're now ready to use it
```swift
analytics.send("hello world")
```

## The core concepts

### Analytics
`Analytics` are used to send events and therefore the most important type in SwiftAnalytics, so their use should be as simple as possible.

### Analytics.Event
`Analytics.Event` is a type that represents an event that should be sent. It has a name and a dictionary of parameters. Example:
```swift
let event = Analytics.Event("hello world", parameters: ["foo": "bar"])
// or
let event = Analytics.Event("hello world").with("foo", "bar")
```

### Analytics parameters
`Analytics` has a parameters that can be shared across all events sent by the same instance of `Analytics`. Example:
```swift
var analytics = Analytics()
analytics.parameters["user-id"] = "\(UUID())"
analytics.send("hello world")
```
There are some helper functions to set parameters:
```swift
let analytics2 = analytics1
	.with("user-id", UUID())
  .with("user-name", "Alice")

let analytics3 = analytics2
    .with(["session-id": UUID()])
```

## Codable Support

SwiftAnalytics provides excellent support for Swift's `Codable` protocol, making it easy to work with structured data in your analytics events.

### Using Encodable Types as Parameters

You can directly use any `Encodable` type as parameters:

```swift
struct UserInfo: Codable {
    let id: String
    let name: String
    let age: Int
}

let userInfo = UserInfo(id: "123", name: "Alice", age: 30)

// Create an event with Encodable parameters
let event = try Analytics.Event("user_profile_viewed", parameters: userInfo)

// Or add Encodable parameters to existing analytics
let analytics = Analytics()
    .with("user", userInfo)
    .with("session_id", UUID())
```

### Adding Individual Encodable Parameters

You can add individual parameters using any `Encodable` type:

```swift
let analytics = Analytics()
    .with("user_id", UUID())
    .with("timestamp", Date())
    .with("is_premium", true)
    .with("metadata", ["version": "1.2.3", "platform": "iOS"])
```

### JSON String Representation

All `Analytics.ParametersValue` instances provide a `jsonString` property for easy serialization:

```swift
let parameters: Analytics.Parameters = [
    "user_id": "123",
    "preferences": ["theme": "dark", "notifications": true],
    "scores": [95, 87, 92]
]

for (key, value) in parameters {
    print("\(key): \(value.jsonString)")
}
// Output:
// user_id: "123"
// preferences: {"notifications":true,"theme":"dark"}
// scores: [95,87,92]
```

The `jsonString` property automatically handles:
- Proper JSON escaping for strings
- Sorted keys in dictionaries for consistent output
- Special float values (Infinity, -Infinity, NaN)
- Nested structures

## On the implementation of a analytics backend (a AnalyticsHandler)
Note: If you don't want to implement a custom analytics backend, everything in this section is probably not very relevant, so please feel free to skip.

To become a compatible analytics backend that all SwiftAnalytics consumers can use, you need to do two things: 
1. Implement a type (usually a struct) that implements AnalyticsHandler, a protocol provided by SwiftAnalytics
2. Instruct SwiftAnalytics to use your analytics backend implementation.

an AnalyticsHandler or analytics backend implementation is anything that conforms to the following protocol
```swift
public protocol AnalyticsHandler {
    
    var parameters: Analytics.Parameters { get set }
    func send(event: Analytics.Event, file: String, function: String, line: UInt)
}
```
Where `parameters` is a dictionary of parameters that can be shared across all events sent by the same instance of `AnalyticsHandler`, and `send(event:file:function:line:)` is a function that sends an event.

Instructing SwiftAnalytics to use your analytics backend as the one the whole application (including all libraries) should use is very simple:

```swift
AnalyticsSystem.bootstrap(MyAnalyticsHandler())
```

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/swift-analytics.git", from: "1.9.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["SwiftAnalytics"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

swift-analytics is available under the MIT license. See the LICENSE file for more info.
