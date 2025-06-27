import UIKit

/// Конфигурация ячейки количества отзывов. Содержит данные для отображения в ячейке.
struct ReviewsCountCellConfig: TableCellConfig {

	/// Идентификатор для переиспользования ячейки.
	static let reuseId = String(describing: ReviewsCountCellConfig.self)
	/// Текст с количеством отзывов.
	let countText: NSAttributedString
	/// Отступы от краёв ячейки до её содержимого.
	private let insets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 9.0, right: 12.0)

	/// Метод обновления ячейки.
	/// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
	func update(cell: UITableViewCell) {
		cell.textLabel?.attributedText = countText
		cell.textLabel?.textAlignment = .center
		cell.selectionStyle = .none
	}

	/// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
	/// Вызывается из `heightForRowAt:` делегата таблицы.
	func height(with size: CGSize) -> CGFloat {
		let textWidth = size.width - insets.left - insets.right

		let boundingRect = countText.boundingRect(
			with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
			options: [.usesLineFragmentOrigin, .usesFontLeading],
			context: nil
		)

		return ceil(boundingRect.height) + insets.top + insets.bottom
	}

}
