import Foundation
import Nuke
import UIKit

struct GameDayWebcastCellViewModel {
    let title: String
    let name: String
    let channel: String
    let viewerCount: Int
    let thumbnail: String
}

class GameDayWebcastCollectionViewCell: UICollectionViewCell, Reusable {

    var viewModel: GameDayWebcastCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.text = viewModel.title
        nameLabel.text = viewModel.name

        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
            transition: .fadeIn(duration: 0.33)
        )

        if let url = URL(string: viewModel.thumbnail) {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()

            Nuke.loadImage(with: url, options: options, into: previewImageView, progress: nil) { result in
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
        } else {
            // TODO: Show some error image here
            loadingIndicator.isHidden = true
        }
    }

}
