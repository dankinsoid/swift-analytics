import Foundation

/// The `AnalyticsSystem` is a global facility where the default analytics backend implementation (`AnalyticsHandler`) can be
/// configured. `AnalyticsSystem` is set up just once in a given program to set up the desired analytics backend
/// implementation.
public enum AnalyticsSystem {

	private static let _handler = HandlerBox { NOOPAnalyticsHandler.instance }

	/// `bootstrap` is an one-time configuration function which globally selects the desired analytics backend
	/// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
	/// lead to undefined behaviour, most likely a crash.
	///
	/// - parameters:
	///     - handler: The desired analytics backend implementation.
	public static func bootstrap(_ handler: @autoclosure @escaping () -> AnalyticsHandler) {
		_handler.replaceHandler(handler, validate: true)
	}

	/// for our testing we want to allow multiple bootstrapping
	static func bootstrapInternal(_ handler: @autoclosure @escaping () -> AnalyticsHandler) {
		_handler.replaceHandler(handler, validate: false)
	}

	/// Returns a reference to the configured handler.
	static var handler: AnalyticsHandler {
		_handler.underlying()
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
		fileprivate var _underlying: () -> AnalyticsHandler
		private var initialized = false

		init(_ underlying: @escaping () -> AnalyticsHandler) {
			_underlying = underlying
		}

		func replaceHandler(_ factory: @escaping () -> AnalyticsHandler, validate: Bool) {
			lock.withWriterLock {
				precondition(!validate || !self.initialized, "analytics system can only be initialized once per process.")
				self._underlying = factory
				self.initialized = true
			}
		}

		var underlying: () -> AnalyticsHandler {
			lock.withReaderLock {
				self._underlying
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
