import UIKit

class MatchCollectionViewCell: UICollectionViewCell, Reusable {

    var viewModel: MatchViewModel? {
        didSet {
            matchSummaryView.viewModel = viewModel
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private var matchSummaryView: MatchSummaryView!

}
