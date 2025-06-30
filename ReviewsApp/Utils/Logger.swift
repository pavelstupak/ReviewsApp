import Foundation

enum LogLevel: String {
	case debug = "DEBUG"
	case info = "INFO"
	case warn = "WARNING"
	case error = "ERROR"
}

final class Logger {

	// Общий экземпляр Singleton
	static let shared = Logger()

	private init() {}

	func log(_ message: String, level: LogLevel) {
		let timestamp = formattedTimestamp()
		print("[\(timestamp)] [\(level.rawValue)] \(message)")
	}

	func debug(_ message: String) { log(message, level: .debug) }
	func info(_ message: String) { log(message, level: .info) }
	func warn(_ message: String) { log(message, level: .warn) }
	func error(_ message: String) { log(message, level: .error) }

	private func formattedTimestamp() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss.SSS"
		return formatter.string(from: Date())
	}
}
