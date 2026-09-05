import PureLayout
import UIKit

class MatchCollectionViewCell: UICollectionViewListCell, Reusable {

    var viewModel: MatchViewModel? {
        didSet {
            matchSummaryView.viewModel = viewModel
        }
    }

    private let matchSummaryView: MatchSummaryView = {
        let view = MatchSummaryView()
        view.configureForAutoLayout()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        matchSummaryView.resetView()
    }

    private func setUpView() {
        accessories = [.disclosureIndicator()]

        contentView.addSubview(matchSummaryView)
        matchSummaryView.autoPinEdge(toSuperviewMargin: .leading)
        matchSummaryView.autoPinEdge(toSuperviewMargin: .trailing)
        matchSummaryView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        matchSummaryView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        matchSummaryView.autoSetDimension(.height, toSize: 60, relation: .greaterThanOrEqual)
    }

}
