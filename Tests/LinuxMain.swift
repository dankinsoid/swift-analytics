import XCTest

#if os(Linux) || os(FreeBSD) || os(Windows) || os(Android)
@testable import LoggingTests

XCTMain([
    testCase(CompatibilityTest.allTests),
    testCase(GlobalLoggerTest.allTests),
    testCase(LocalLoggerTest.allTests),
    testCase(LoggingTest.allTests),
    testCase(MDCTest.allTests),
    testCase(MetadataProviderTest.allTests),
])
#endif
