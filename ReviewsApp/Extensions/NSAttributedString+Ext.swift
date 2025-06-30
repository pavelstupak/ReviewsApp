import UIKit

extension NSAttributedString {

    /// Метод проверяет, будет ли пуста строка, если удалить пробелы и переносы строк в начале и конце строки.
    func isEmpty(trimmingCharactersIn set: CharacterSet = .whitespacesAndNewlines) -> Bool {
        string.trimmingCharacters(in: set).isEmpty
    }

    /// Метод возвращает шрифт атрибутированной строки по индексу `location`.
    func font(at location: Int = .zero) -> UIFont? {
		guard length > 0 else { return nil }
        return attributes(at: location, effectiveRange: nil)[.font] as? UIFont
    }

	/// Метод возвращает высоту строки  с данным ограничением по ширине `width`.
	func actualHeight(for width: CGFloat) -> CGFloat {
		boundingRect(
			with: CGSize(width: width, height: .greatestFiniteMagnitude),
			options: [.usesLineFragmentOrigin, .usesFontLeading],
			context: nil
		).height
	}

}
