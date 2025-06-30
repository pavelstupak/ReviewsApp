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

		cell.reviewTextLabel.numberOfLines = maxLines
		cell.showMoreButton.isHidden = !layout.showShowMoreButton
		cell.config = self

		cell.showMoreButton.addAction(UIAction { _ in
			self.onTapShowMore(self.id)
		}, for: .touchUpInside)

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

    override func layoutSubviews() {
        super.layoutSubviews()
		guard let layout = currentLayout else { return }
		avatarImage.frame = layout.avatarImageFrame
		usernameLabel.frame = layout.usernameLabelFrame
		ratingImage.frame = layout.ratingImageFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
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
		avatarImage.image = Self.avatarPlaceholder
		avatarImage.layer.cornerRadius = Layout.avatarCornerRadius
		avatarImage.contentMode = .scaleAspectFill
		avatarImage.clipsToBounds = true
	}

	func setupRatingImage() {
		contentView.addSubview(ratingImage)
	}

	func setupUsernameLabel() {
		contentView.addSubview(usernameLabel)
	}

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

	// Высота ячейки.
	private(set) var height: CGFloat = 0
	// Флаг необходимости отображения кнопки "Показать полностью...".
	private(set) var showShowMoreButton: Bool = false

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
	fileprivate static let ratingImageSize = CGSize(width: 84.0, height: 16.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

	private(set) var avatarImageFrame = CGRect.zero
	private(set) var usernameLabelFrame = CGRect.zero
	private(set) var ratingImageFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

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

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
