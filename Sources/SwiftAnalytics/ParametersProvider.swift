#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import CRT
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#else
#error("Unsupported runtime")
#endif

public extension Analytics {

    /// A `ParametersProvider` is used to automatically inject runtime-generated parameters
    /// to all events emitted by an analytics.
    ///
    /// ### Example
    /// A parameters provider may be used to automatically inject parameters such as
    /// trace IDs:
    ///
    /// ```swift
    /// import Tracing // https://github.com/apple/swift-distributed-tracing
    ///
    /// let parametersProvider = ParametersProvider {
    ///     guard let traceID = Baggage.current?.traceID else { return nil }
    ///     return ["traceID": "\(traceID)"]
    /// }
    /// let analytics = Analytics(parametersProvider: ParametersProvider)
    /// var baggage = Baggage.topLevel
    /// baggage.traceID = 42
    /// Baggage.withValue(baggage) {
    ///     analytics.send("hello") // automatically includes ["traceID": "42"] parameters
    /// }
    /// ```
    ///
    /// I recommend referring to [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing)
    /// for parameters providers which make use of its tracing and parameters propagation infrastructure. It is however
    /// possible to make use of parameters providers independently of tracing and instruments provided by that library,
    /// if necessary.
    struct ParametersProvider: _SwiftAnalyticsSendableAnalyticsHandler {
        // Provide ``Logger.Metadata`` from current context.
        #if swift(>=5.5) && canImport(_Concurrency) // we could instead typealias the function type, but it was requested that we avoid this for better developer experience
        @usableFromInline
        let _provideParameters: @Sendable () -> Parameters
        #else
        @usableFromInline
        let _provideParameters: () -> Parameters
        #endif

        // Create a new `MetadataProvider`.
        //
        // - Parameter provideParameters: A closure extracting metadata from the current execution context.
        #if swift(>=5.5) && canImport(_Concurrency)
        public init(_ provideParameters: @escaping @Sendable () -> Parameters) {
            _provideParameters = provideParameters
        }

        #else
        public init(_ provideParameters: @escaping () -> Parameters) {
            _provideParameters = provideParameters
        }
        #endif

        /// Invoke the metadata provider and return the generated contextual ``Logger/Metadata``.
        public func get() -> Parameters {
            _provideParameters()
        }
    }
}

public extension Analytics.ParametersProvider {

    /// A pseudo-`ParametersProvider` that can be used to merge parameters from multiple other `ParametersProvider`s.
    ///
    /// ### Merging conflicting keys
    ///
    /// `ParametersProvider`s are invoked left to right in the order specified in the `providers` argument.
    /// In case multiple providers try to add a value for the same key, the last provider "wins" and its value is being used.
    ///
    /// - Parameter providers: An array of `ParametersProvider`s to delegate to. The array must not be empty.
    /// - Returns: A pseudo-`ParametersProvider` merging parameters from the given `ParametersProvider`s.
    static func multiplex(_ providers: [Analytics.ParametersProvider]) -> Analytics.ParametersProvider? {
        Analytics.ParametersProvider {
            providers.reduce(into: [:]) { parameters, provider in
                let providedParameters = provider.get()
                guard !providedParameters.isEmpty else {
                    return
                }
                parameters.merge(providedParameters, uniquingKeysWith: { _, rhs in rhs })
            }
        }
    }
}
