import Foundation
import UIKit

class EventGameDayTableViewCell: UITableViewCell, Reusable {

    var viewModel: EventGameDayCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var rightImageView: UIImageView!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        rightImageView.isHidden = false
        switch viewModel.gameDayStatus {
        case .none:
            rightImageView.isHidden = true
        case .online:
            rightImageView.tintColor = UIColor.systemGreen
            rightImageView.image = UIImage(systemName: "video.fill")
        case .offline:
            rightImageView.tintColor = UIColor.systemGray
            rightImageView.image = UIImage(systemName: "video.slash.fill")
        }
    }

}
