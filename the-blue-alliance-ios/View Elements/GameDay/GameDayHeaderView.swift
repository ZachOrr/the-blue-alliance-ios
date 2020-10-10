import UIKit

class GameDayHeaderView: UICollectionReusableView, Reusable {

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        // Possibly headline if title1 is too big
        let font = UIFont.preferredFont(forTextStyle: .title1)
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        label.font = fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: font.pointSize, weight: .semibold))
        label.textColor = .label
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

}
