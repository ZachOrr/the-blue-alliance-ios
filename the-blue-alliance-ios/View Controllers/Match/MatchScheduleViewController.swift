import Foundation
import TBAData
import UIKit

class MatchScheduleViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!

    let matches: [Match]

    init(matches: [Match]) {
        self.matches = matches

        super.init(nibName: "MatchSchedule", bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.matches = []

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(MatchCollectionViewCell.self)
        collectionView.dataSource = self

        let collectionViewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewLayout.estimatedItemSize = CGSize(width: 553, height: 138)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let match = matches[indexPath.row]
        let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as MatchCollectionViewCell
        cell.viewModel = MatchViewModel(match: match, baseTeamKeys: ["frc2337"])
        return cell
    }

}
