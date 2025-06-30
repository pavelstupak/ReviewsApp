import UIKit

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

	// Высота ячейки.
	private(set) var height: CGFloat = 0

	// MARK: - Размеры

	static let avatarSize = CGSize(width: 36.0, height: 36.0)
	static let ratingImageSize = CGSize(width: 84.0, height: 16.0)
	static let avatarCornerRadius = 18.0
	static let photoCornerRadius = 8.0

	static let photoSize = CGSize(width: 55.0, height: 66.0)
	static let showMoreButtonSize = Config.showMoreText.size()

	// MARK: - Отступы

	/// Отступы от краёв ячейки до её содержимого.
	static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

	/// Горизонтальный отступ от аватара до имени пользователя.
	static let avatarToUsernameSpacing = 10.0
	/// Вертикальный отступ от имени пользователя до вью рейтинга.
	static let usernameToRatingSpacing = 6.0
	/// Вертикальный отступ от вью рейтинга до текста (если нет фото).
	static let ratingToTextSpacing = 6.0
	/// Вертикальный отступ от вью рейтинга до фото.
	static let ratingToPhotosSpacing = 10.0
	/// Горизонтальные отступы между фото.
	static let photosSpacing = 8.0
	/// Вертикальный отступ от фото (если они есть) до текста отзыва.
	static let photosToTextSpacing = 10.0
	/// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
	static let reviewTextToCreatedSpacing = 6.0
	/// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
	static let showMoreToCreatedSpacing = 6.0

	// MARK: - Init
	convenience init(config: ReviewCellConfig, maxWidth: CGFloat) {
		self.init()
		_ = self.height(config: config, maxWidth: maxWidth)
	}

	// MARK: - Расчёт фреймов и высоты ячейки

	/// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
	func height(config: Config, maxWidth: CGFloat) -> CGFloat {
		var maxX = insets.left
		var maxY = insets.top
		var showShowMoreButton = false

		avatarImageFrame = CGRect(
			origin: CGPoint(x: maxX, y: maxY),
			size: Layout.avatarSize
		)

		maxX = avatarImageFrame.maxX + avatarToUsernameSpacing

		let width = maxWidth - insets.left - insets.right - avatarImageFrame.width - avatarToUsernameSpacing

		// Высота имени пользователя.
		let usernameHeight = config.username.boundingRect(width: width).size.height

		usernameLabelFrame = CGRect(
			origin: CGPoint(x: maxX, y: maxY),
			size: config.username.boundingRect(width: width, height: usernameHeight).size
		)

		maxY = usernameLabelFrame.maxY + usernameToRatingSpacing

		ratingImageFrame = CGRect(
			origin: CGPoint(x: maxX, y: maxY),
			size: Layout.ratingImageSize
		)

		maxY = ratingImageFrame.maxY + ratingToTextSpacing

		if !config.reviewText.isEmpty() {
			// Высота текста с текущим ограничением по количеству строк.
			let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
			// Максимально возможная высота текста, если бы ограничения не было.
			let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
			// Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
			showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

			reviewTextLabelFrame = CGRect(
				origin: CGPoint(x: maxX, y: maxY),
				size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
			)
			maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
		}

		if showShowMoreButton {
			showMoreButtonFrame = CGRect(
				origin: CGPoint(x: maxX, y: maxY),
				size: Self.showMoreButtonSize
			)
			maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
		} else {
			showMoreButtonFrame = .zero
		}

		createdLabelFrame = CGRect(
			origin: CGPoint(x: maxX, y: maxY),
			size: config.created.boundingRect(width: width).size
		)

		self.height = max(avatarImageFrame.maxY, createdLabelFrame.maxY) + insets.bottom
		return self.height
	}

}
