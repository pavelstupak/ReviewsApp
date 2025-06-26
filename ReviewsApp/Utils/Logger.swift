import Foundation

final class Logger {
	
	static let shared = Logger()

	private init() {}

	func debug(_ message: String) {
		#if DEBUG
		print(message)
		#endif
	}

	func info(_ message: String) {
		#if DEBUG
		print(message)
		#endif
	}

	func warn(_ message: String) {
		#if DEBUG
		print(message)
		#else
		// ToDo: Отправка в систему логирования
		#endif
	}

	func error(_ message: String) {
		#if DEBUG
		print(message)
		#else
		// ToDo: Отправка crash-репорта
		#endif
	}

}
