import Foundation

/// The `AnalyticsSystem` is a global facility where the default analytics backend implementation (`AnalyticsHandler`) can be
/// configured. `AnalyticsSystem` is set up just once in a given program to set up the desired analytics backend
/// implementation.
public enum AnalyticsSystem {

	private static let _handler = HandlerBox(NOOPAnalyticsHandler.instance)

	/// `bootstrap` is an one-time configuration function which globally selects the desired analytics backend
	/// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
	/// lead to undefined behaviour, most likely a crash.
	///
	/// - parameters:
	///     - handler: The desired analytics backend implementation.
    ///     - parametersProvider: The parameters provider to be used by the handler.
	public static func bootstrap(_ handler: AnalyticsHandler, parametersProvider: Analytics.ParametersProvider? = nil) {
        _handler.replaceHandler(handler, provider: parametersProvider, validate: true)
	}

	/// for our testing we want to allow multiple bootstrapping
    static func bootstrapInternal(_ handler: AnalyticsHandler, parametersProvider: Analytics.ParametersProvider? = nil) {
		_handler.replaceHandler(handler, provider: parametersProvider, validate: false)
	}

	/// Returns a reference to the configured handler.
	static var handler: AnalyticsHandler {
		_handler.underlying
	}
    
    static var parametersProvider: Analytics.ParametersProvider? {
        _handler.underlyingProvider
    }

	/// Acquire a writer lock for the duration of the given block.
	///
	/// - Parameter body: The block to execute while holding the lock.
	/// - Returns: The value returned by the block.
	public static func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
		try _handler.withWriterLock(body)
	}

	private final class HandlerBox {

		private let lock = ReadWriteLock()
		private var _underlying: AnalyticsHandler
        private var _underlyingProvider: Analytics.ParametersProvider?
		private var initialized = false

		init(_ underlying: AnalyticsHandler) {
			_underlying = underlying
		}

        func replaceHandler(_ factory: AnalyticsHandler, provider: Analytics.ParametersProvider?, validate: Bool) {
			lock.withWriterLock {
				precondition(!validate || !self.initialized, "analytics system can only be initialized once per process.")
				self._underlying = factory
                self._underlyingProvider = provider
				self.initialized = true
			}
		}

		var underlying: AnalyticsHandler {
			lock.withReaderLock {
				self._underlying
			}
		}
    
        var underlyingProvider: Analytics.ParametersProvider? {
            lock.withReaderLock {
                self._underlyingProvider
            }
        }

		func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
			try lock.withWriterLock(body)
		}
	}
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
extension AnalyticsSystem: Sendable {}
#endif
