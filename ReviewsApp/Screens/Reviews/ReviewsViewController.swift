import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
		viewModel.onTapShowMore = { [weak self] id in
			self?.expandReview(with: id)
		}
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()

		reviewsView.tableView.rowHeight = UITableView.automaticDimension
		// Примерная высота для ячейки с отзывом из 1 строки
		reviewsView.tableView.estimatedRowHeight = 100
    }

	func expandReview(with id: UUID) {
		if let index = viewModel.showMoreReview(with: id) {
			let indexPath = IndexPath(row: index, section: 0)
			UIView.performWithoutAnimation {
				reviewsView.tableView.reloadRows(at: [indexPath], with: .none)
			}
		}
	}

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] _ in
            reviewsView?.tableView.reloadData()
        }
    }

}
