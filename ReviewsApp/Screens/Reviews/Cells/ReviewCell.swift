import UIKit

/// Конфигурация ячейки отзыва. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
	/// Имя пользователя.
	let username: NSAttributedString
	/// Рейтинг.
	let rating: Int
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

	init(
		username: NSAttributedString,
		rating: Int,
		reviewText: NSAttributedString,
		created: NSAttributedString,
		maxLines: Int = 3,
		onTapShowMore: @escaping (UUID) -> Void
	) {
		self.username = username
		self.rating = rating
		self.reviewText = reviewText
		self.created = created
		self.maxLines = maxLines
		self.onTapShowMore = onTapShowMore
	}

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }

		cell.usernameLabel.attributedText = username
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created

		let layout = ReviewCellLayout(config: self, maxWidth: cell.bounds.width)
		cell.currentLayout = layout

		cell.ratingImage.image = RatingRenderer.shared.ratingImage(rating)
		cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
	// TODO: Оптимизировать создание layout для перфоманса.
    func height(with size: CGSize) -> CGFloat {
		let layout = ReviewCellLayout(config: self, maxWidth: size.width)
		return layout.height
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

	static let avatarPlaceholder = UIImage(named: "avatar")

    fileprivate var config: Config?
	fileprivate var currentLayout: ReviewCellLayout?

	fileprivate let avatarImage = UIImageView()
	fileprivate let usernameLabel = UILabel()
	fileprivate var ratingImage = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
		setupAvatarImage()
		setupUsernameLabel()
		setupRatingImage()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }

	func setupAvatarImage() {
		contentView.addSubview(avatarImage)
		avatarImage.translatesAutoresizingMaskIntoConstraints = false
		avatarImage.image = Self.avatarPlaceholder
		avatarImage.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
		avatarImage.contentMode = .scaleAspectFill
		avatarImage.clipsToBounds = true
	}

	func setupRatingImage() {
		contentView.addSubview(ratingImage)
		ratingImage.translatesAutoresizingMaskIntoConstraints = false
	}

	func setupUsernameLabel() {
		contentView.addSubview(usernameLabel)
		usernameLabel.translatesAutoresizingMaskIntoConstraints = false
	}

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
		reviewTextLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
		createdLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
		showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
