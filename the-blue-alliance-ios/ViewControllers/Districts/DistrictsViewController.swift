import CoreData
import Foundation
import TBAAPI
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBATableViewController {

    var refreshTask: Task<Void, Never>?

    weak var delegate: DistrictsViewControllerDelegate?
    var year: Int {
        didSet {
            refresh()
        }
    }
    @SortedKeyPath(comparator: KeyPathComparator(\District.name)) var districts: [District]? = nil {
        didSet {
            updateDataSource()
        }
    }

    private var dataSource: TableViewDataSource<String, District>!

    // MARK: - Init

    init(year: Int, dependencies: Dependencies) {
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        setupDataSource()
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let districts else {
            return
        }
        guard indexPath.row < districts.count else {
            return
        }
        let district = districts[indexPath.row]
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func setupDataSource () {
        dataSource = TableViewDataSource<String, District>(tableView: tableView) { (tableView, indexPath, district) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
            cell.textLabel?.text = district.name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        dataSource.simpleStatefulDelegate = self
        dataSource.delegate = self
    }

    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("districts", atIndex: 0)
        if let districts {
            snapshot.appendItems(districts)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

extension DistrictsViewController: SimpleRefreshable {    

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        refreshTask = Task {
            await refresh()
        }
    }

    func refresh() async {
        do {
            self.districts = try await dependencies.api.getDistricts(year: year)
            endRefresh()
        } catch {
            showNoDataView() // TODO: Error?
        }
    }
}

extension DistrictsViewController: Stateful {

    var noDataText: String? {
        return "No districts for year"
    }

}
