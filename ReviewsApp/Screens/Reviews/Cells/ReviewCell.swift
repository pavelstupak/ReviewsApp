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
        cell.createdLabel.attributedText = created
		cell.ratingImage.image = RatingRenderer.shared.ratingImage(rating)
		cell.reviewTextLabel.numberOfLines = maxLines
		cell.config = self

		let maxTextWidth = cell.contentView.bounds.width - ReviewCellLayout.insets.left - ReviewCellLayout.insets.right - ReviewCellLayout.avatarSize.width - ReviewCellLayout.avatarToUsernameSpacing
		let actualTextHeight = reviewText.actualHeight(for: maxTextWidth)

		let lineHeight = reviewText.font()?.lineHeight ?? .zero
		let currentTextHeight = lineHeight * CGFloat(maxLines)
		let hasText = !reviewText.isEmpty()
		cell.showMoreButton.isHidden = !hasText || maxLines == .zero || actualTextHeight <= currentTextHeight

		if cell.showMoreButton.isHidden {
			cell.createdLabelTopToShowMoreConstraint.isActive = false
			cell.createdLabelTopToReviewTextConstraint.isActive = true
		} else {
			cell.createdLabelTopToReviewTextConstraint.isActive = false
			cell.createdLabelTopToShowMoreConstraint.isActive = true
		}
    }

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

	fileprivate var createdLabelTopToShowMoreConstraint: NSLayoutConstraint!
	fileprivate var createdLabelTopToReviewTextConstraint: NSLayoutConstraint!

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
		setupShowMoreButton()
        setupCreatedLabel()
    }

	func setupAvatarImage() {
		contentView.addSubview(avatarImage)
		avatarImage.translatesAutoresizingMaskIntoConstraints = false
		avatarImage.image = Self.avatarPlaceholder
		avatarImage.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
		avatarImage.contentMode = .scaleAspectFill
		avatarImage.clipsToBounds = true

		NSLayoutConstraint.activate([
			avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ReviewCellLayout.insets.left),
			avatarImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ReviewCellLayout.insets.top),
			avatarImage.widthAnchor.constraint(equalToConstant: ReviewCellLayout.avatarSize.width),
			avatarImage.heightAnchor.constraint(equalToConstant: ReviewCellLayout.avatarSize.height)
		])

	}

	func setupUsernameLabel() {
		contentView.addSubview(usernameLabel)
		usernameLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: ReviewCellLayout.avatarToUsernameSpacing),
			usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ReviewCellLayout.insets.top),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ReviewCellLayout.insets.right)
		])

	}

	func setupRatingImage() {
		contentView.addSubview(ratingImage)
		ratingImage.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			ratingImage.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: ReviewCellLayout.avatarToUsernameSpacing),
			ratingImage.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: ReviewCellLayout.usernameToRatingSpacing),
			ratingImage.widthAnchor.constraint(equalToConstant: ReviewCellLayout.ratingImageSize.width),
			ratingImage.heightAnchor.constraint(equalToConstant: ReviewCellLayout.ratingImageSize.height)
		])

	}

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
		reviewTextLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewTextLabel.lineBreakMode = .byWordWrapping

		NSLayoutConstraint.activate([
			reviewTextLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: ReviewCellLayout.avatarToUsernameSpacing),
			reviewTextLabel.topAnchor.constraint(equalTo: ratingImage.bottomAnchor, constant: ReviewCellLayout.ratingToTextSpacing),
			reviewTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ReviewCellLayout.insets.right)
		])

    }

	func setupShowMoreButton() {
		contentView.addSubview(showMoreButton)
		showMoreButton.translatesAutoresizingMaskIntoConstraints = false
		showMoreButton.contentVerticalAlignment = .fill
		showMoreButton.setAttributedTitle(ReviewCellLayout.showMoreText, for: .normal)
		showMoreButton.isHidden = true

		var config = UIButton.Configuration.plain()
		config.contentInsets = .zero
		config.titlePadding = 0
		showMoreButton.configuration = config

		NSLayoutConstraint.activate([
			showMoreButton.leadingAnchor.constraint(equalTo: reviewTextLabel.leadingAnchor),
			showMoreButton.topAnchor.constraint(equalTo: reviewTextLabel.bottomAnchor, constant: ReviewCellLayout.reviewTextToCreatedSpacing)

		])

	}

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
		createdLabel.translatesAutoresizingMaskIntoConstraints = false

		createdLabelTopToShowMoreConstraint = createdLabel.topAnchor.constraint(
			equalTo: showMoreButton.bottomAnchor,
			constant: ReviewCellLayout.showMoreToCreatedSpacing
		)

		createdLabelTopToReviewTextConstraint = createdLabel.topAnchor.constraint(
			equalTo: reviewTextLabel.bottomAnchor,
			constant: ReviewCellLayout.reviewTextToCreatedSpacing
		)

		createdLabelTopToReviewTextConstraint.isActive = true

		NSLayoutConstraint.activate([
			createdLabel.leadingAnchor.constraint(equalTo: reviewTextLabel.leadingAnchor),
			createdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ReviewCellLayout.insets.right),
			createdLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ReviewCellLayout.insets.bottom)
		])
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
