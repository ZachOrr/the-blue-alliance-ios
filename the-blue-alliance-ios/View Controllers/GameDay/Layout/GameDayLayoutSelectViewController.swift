import Foundation
import UIKit

private enum Section {
    case main
}

protocol GameDayLayoutSelectViewControllerDelegate: AnyObject {
    func layoutSelected(layout: GameDayLayout)
}

class GameDayLayoutSelectViewController: UITableViewController {

    public weak var delegate: GameDayLayoutSelectViewControllerDelegate?

    private let currentLayout: GameDayLayout
    private var tableViewDataSource: TableViewDataSource<Section, GameDayLayout>!

    init(currentLayout: GameDayLayout) {
        self.currentLayout = currentLayout

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(BasicTableViewCell.self)
        tableView.tableFooterView = nil
        tableView.isScrollEnabled = false

        setupDataSource()
        tableView.dataSource = tableViewDataSource
    }

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<Section, GameDayLayout>(tableView: tableView) { (tableView, indexPath, layout) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
            cell.textLabel?.text = layout.title
            if self.currentLayout == layout {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.imageView?.image = layout.image
            return cell
        }
        self.tableViewDataSource = TableViewDataSource(dataSource: dataSource)

        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(GameDayLayout.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let layout = tableViewDataSource.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.layoutSelected(layout: layout)
        dismiss(animated: true, completion: nil)
    }

}
