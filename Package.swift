// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swift-analytics",
	products: [
		.library(name: "SwiftAnalytics", targets: ["SwiftAnalytics"]),
	],
	dependencies: [],
	targets: [
		.target(name: "SwiftAnalytics", dependencies: []),
		.testTarget(name: "SwiftAnalyticsTests", dependencies: ["SwiftAnalytics"]),
	]
)
