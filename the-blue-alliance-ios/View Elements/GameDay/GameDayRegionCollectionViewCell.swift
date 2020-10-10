import Foundation
import UIKit

struct GameDayRegionViewModel {
    let name: String
    let webcastCount: Int
}

class GameDayRegionCollectionViewCell: UICollectionViewCell, Reusable {

    var viewModel: GameDayRegionViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var webcastsOnlineLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        nameLabel.text = viewModel.name
        webcastsOnlineLabel.text = "\(viewModel.webcastCount) webcasts online"
    }

}
