import TBAData
import UIKit

private enum Section {
    case main
}

class GameDayViewController: UIViewController {

    private var layout: GameDayLayout {
        didSet {
            collectionView.setCollectionViewLayout(layout.collectionViewLayout, animated: true)
        }
    }

    private var collectionView: UICollectionView!

    private var players: [WebcastPlayer?]

    init(webcasts: [Webcast]) {
        // On iPhone - set layout to default to a single-view
        // On iPad - set layout to be # of webcasts (limit of 4)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.layout = GameDayLayout.layoutFor(webcasts.count)
        } else {
            self.layout = .single
        }
        self.players = webcasts.map { TwitchPlayer(webcast: $0) } + Array.init(repeating: nil, count: max(GameDayLayout.maxNumberOfItems - webcasts.count, 0))

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true // TODO: This needs to be true when not in the root
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.split.2x1.fill"), style: .plain, target: self, action: #selector(showSelectLayout))

        configureHierarchy()
    }

    // MARK: - Private Methods

    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: layout.collectionViewLayout)
        collectionView.registerReusableCell(BasicCollectionViewCell.self)

        collectionView.backgroundColor = UIColor.black

        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewMargins()

        collectionView.dataSource = self
        collectionView.delegate = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
        longPressGesture.minimumPressDuration = 0.3
     }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            animatePickingUpCell(at: selectedIndexPath, center: gesture.location(in: collectionView))
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.endInteractiveMovement()
            animatePuttingDownCell(at: selectedIndexPath)
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    private func animatePickingUpCell(at indexPath: IndexPath, center: CGPoint) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell.alpha = GameDayCollectionViewLayout.movingCellAlpha
            cell.transform = CGAffineTransform(scaleX: GameDayCollectionViewLayout.movingCellScale, y: GameDayCollectionViewLayout.movingCellScale)
            cell.center = center
        })
    }

    private func animatePuttingDownCell(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell.alpha = 1.0
            cell.transform = CGAffineTransform.identity
        })
    }

    @objc private func showSelectLayout() {
        let layoutController = GameDayLayoutSelectViewController(currentLayout: layout)
        layoutController.delegate = self
        let navigationController = UINavigationController(rootViewController: layoutController)
        present(navigationController, animated: true, completion: nil)
    }

}

extension GameDayViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layout.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as BasicCollectionViewCell

        if let player = players[indexPath.row] {
            cell.addSubview(player)
            player.autoPinEdgesToSuperviewEdges()
        } else {
            let button = RoundedButton(title: "Select Webcast", titleColor: .black, backgroundColor: .white)
            cell.addSubview(button)
            button.autoCenterInSuperview()
            button.autoMatch(.width, to: .width, of: cell, withOffset: 16.0, relation: .lessThanOrEqual)
        }

        return cell
    }

}

extension GameDayViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        players.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

}

extension GameDayViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        // Ensure this looks right - for now, accept all
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath == nil {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        print("Dropped")
    }

}

extension GameDayViewController: GameDayLayoutSelectViewControllerDelegate {

    func layoutSelected(layout: GameDayLayout) {
        self.layout = layout
    }

}
