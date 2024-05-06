import XCTest

#if os(Linux) || os(FreeBSD) || os(Windows) || os(Android)
@testable import SwiftAnalyticsTests

XCTMain([
	testCase(AnalyticsTests.allTests),
])
#endif
