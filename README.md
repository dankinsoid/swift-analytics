# SwiftAnalytics
SwiftAnalytics is an API package which tries to establish a common API the ecosystem can use.
To make analytics really work for real-world workloads, we need SwiftAnalytics-compatible analytics backends which send events to Firebase, Amplitude, DataDog, etc.

## Getting Started

Adding the dependency
To depend on the analytics API package, you need to declare your dependency in your Package.swift:

.package(url: "https://github.com/dankinsoid/swift-analytics.git", from: "1.0.0"),
and to your application/library target, add "SwiftAnalytics" to your dependencies, e.g. like this:
```swift
.target(name: "BestExampleApp", dependencies: [
    .product(name: "SwiftAnalytics", package: "swift-analytics")
],
```
Let's send events
// 1) let's import the SwiftAnalytics API package
```swift
import SwiftAnalytics
```

// 2) we need to create a Analytics
```swift
let analytics = Analytics()
```

// 3) we're now ready to use it
```swift
analytics.send("hello world")
```

## The core concepts

### Analytics
`Analytics` are used to send events and therefore the most important type in SwiftAnalytics, so their use should be as simple as possible.

### Analytics.Event
`Analytics.Event` is a type that represents an event that should be sent. It has a name and a dictionary of parameters. Example:
```swift
let event = Analytics.Event(name: "hello world", parameters: ["foo": "bar"])
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

## On the implementation of a analytics backend (a AnalyticsHandler)
Note: If you don't want to implement a custom analytics backend, everything in this section is probably not very relevant, so please feel free to skip.

To become a compatible analytics backend that all SwiftAnalytics consumers can use, you need to do two things: 
1. Implement a type (usually a struct) that implements AnalyticsHandler, a protocol provided by SwiftAnalytics
2. Instruct SwiftAnalytics to use your analytics backend implementation.

an AnalyticsHandler or analytics backend implementation is anything that conforms to the following protocol
```swift
public protocol AnalyticsHandler {
    
    var parameters: [String: String] { get set }
    func send(event: Analytics.Event, fileID: String, function: String, line: UInt)
}
```
Where `parameters` is a dictionary of parameters that can be shared across all events sent by the same instance of `AnalyticsHandler`, and `send(event:fileID:function:line:)` is a function that sends an event.

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
    .package(url: "https://github.com/dankinsoid/swift-analytics.git", from: "1.0.0")
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
