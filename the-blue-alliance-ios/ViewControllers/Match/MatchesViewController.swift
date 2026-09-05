import Foundation
import MyTBAKit
import TBAAPI
import UIKit

protocol MatchesViewControllerDelegate: AnyObject {
    func showFilter()
    func matchSelected(_ match: Match)
}

private enum MatchListItem: Hashable {
    case header(MatchSection)
    case match(Match)
}

class MatchesViewController: TBACollectionViewController, Refreshable, Stateful {

    weak var delegate: MatchesViewControllerDelegate?
    var query: MatchQueryOptions = MatchQueryOptions.defaultQuery()

    private var state: EventState
    private let teamKey: String?

    private var dataSource: CollectionViewDataSource<MatchSection, MatchListItem>!

    private lazy var matchCellRegistration =
        UICollectionView.CellRegistration<MatchCollectionViewCell, Match> {
            [weak self] cell, _, match in
            guard let self else { return }

            var baseTeamKeys: Set<String> = Set()
            if let teamKey = self.teamKey {
                baseTeamKeys.insert(teamKey)
            }
            if self.query.filter.favorites {
                baseTeamKeys.formUnion(self.favoriteTeamKeys)
            }
            if let event = self.state.event {
                cell.viewModel = MatchViewModel(
                    match: match,
                    event: event,
                    allianceLookup: self.allianceLookup,
                    baseTeamKeys: Array(baseTeamKeys)
                )
            } else {
                cell.viewModel = MatchViewModel(
                    withoutEventContextFor: match,
                    baseTeamKeys: Array(baseTeamKeys)
                )
            }
            cell.accessibilityIdentifier = "match.\(match.key)"
        }

    private lazy var headerCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewListCell, MatchSection> {
            cell,
            _,
            section in
            var content = UIListContentConfiguration.plainHeader()
            content.text = section.title
            content.textProperties.color = .white
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
            content.textProperties.transform = .none
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = UIColor.tableViewHeaderColor
            cell.backgroundConfiguration = background

            cell.tintColor = .white
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }

    private var allMatches: [Match] = []
    private var favoriteTeamKeys: [String] = []
    private var allianceLookup: AllianceLookup?

    lazy var matchQueryBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage.sortFilterIcon,
            style: .plain,
            target: self,
            action: #selector(showFilter)
        )
    }()
    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [matchQueryBarButtonItem]
    }

    // MARK: - Init

    convenience init(event: Event, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .event(event), teamKey: teamKey, dependencies: dependencies)
    }

    // For callers that only have the event key (e.g. TeamAtEventViewController).
    // refresh() upgrades state to `.event` so playoff-aware sectioning kicks in.
    convenience init(eventKey: EventKey, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .key(eventKey), teamKey: teamKey, dependencies: dependencies)
    }

    private init(state: EventState, teamKey: String?, dependencies: Dependencies) {
        self.state = state
        self.teamKey = teamKey

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.headerMode = .firstItemInSection
        let layout = UICollectionViewCompositionalLayout { _, environment in
            let section = NSCollectionLayoutSection.list(
                using: config,
                layoutEnvironment: environment
            )
            section.contentInsets = .zero
            return section
        }

        super.init(collectionViewLayout: layout, dependencies: dependencies)
    }

    private var favoritesStore: FavoritesStore { myTBAStores.favorites }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInsetAdjustmentBehavior = .never

        setupDataSource()

        updateInterface()
    }

    private func updateInterface() {
        if query.isDefault {
            matchQueryBarButtonItem.image = UIImage.sortFilterIcon
        } else {
            matchQueryBarButtonItem.image = UIImage.sortFilterIconActive
        }
    }

    // MARK: Collection View Data Source

    private func setupDataSource() {
        dataSource = CollectionViewDataSource<MatchSection, MatchListItem>(
            collectionView: collectionView
        ) { [matchCellRegistration, headerCellRegistration] collectionView, indexPath, item in
            switch item {
            case .header(let section):
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerCellRegistration,
                    for: indexPath,
                    item: section
                )
            case .match(let match):
                return collectionView.dequeueConfiguredReusableCell(
                    using: matchCellRegistration,
                    for: indexPath,
                    item: match
                )
            }
        }
        dataSource.delegate = self
    }

    private func applyMatches(_ matches: [Match]) {
        let filtered = matches.filter(
            for: teamKey,
            favoriteTeamKeys: query.filter.favorites ? favoriteTeamKeys : nil
        )
        let sorted = filtered.sorted(ascending: !query.sort.reverse)

        var grouped: [MatchSection: [Match]] = [:]
        let playoffType = state.event?.playoffTypeEnum
        for match in sorted {
            let section = MatchSection.section(for: match, playoffType: playoffType)
            grouped[section, default: []].append(match)
        }
        let sortedSections = grouped.keys.sorted(by: query.sort.reverse ? (>) : (<))

        // Capture each section's current expansion state BEFORE any apply()
        // calls, so we can faithfully restore it after the top-level snapshot
        // (which may add/remove/reorder sections) lands.
        var expansionByHeader: [MatchListItem: Bool] = [:]
        for section in dataSource.snapshot().sectionIdentifiers {
            let header = MatchListItem.header(section)
            let current = dataSource.snapshot(for: section)
            if current.contains(header) {
                expansionByHeader[header] = current.isExpanded(header)
            }
        }

        // Apply the top-level snapshot first so section ordering matches
        // sortedSections (handles new sections appearing mid-event, reverse-
        // sort flips, and removed-by-filter sections in a single shot).
        // Sections newly added here come back as empty section snapshots; the
        // per-section loop below rebuilds them with the captured expansion
        // state restored.
        var topSnapshot = NSDiffableDataSourceSnapshot<MatchSection, MatchListItem>()
        topSnapshot.appendSections(sortedSections)
        dataSource.apply(topSnapshot, animatingDifferences: false)

        for section in sortedSections {
            let header = MatchListItem.header(section)
            let items = (grouped[section] ?? []).map { MatchListItem.match($0) }
            // Default new sections to expanded; honor the user's prior choice
            // on sections we've seen before.
            let wasExpanded = expansionByHeader[header] ?? true

            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MatchListItem>()
            sectionSnapshot.append([header])
            sectionSnapshot.append(items, to: header)
            if wasExpanded {
                sectionSnapshot.expand([header])
            }
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: false)
        }

        // Force cell-provider re-run for every visible match even when item
        // hashes are unchanged — the cell rendering depends on external state
        // (query.filter.favorites, favoriteTeamKeys, state.event,
        // allianceLookup) that isn't part of the Match hash. Reconfigure via
        // the collection view (not a flat top-level apply) so the section
        // snapshots' outline hierarchy stays intact. Off-screen cells will
        // pick up the new state on their next dequeue.
        let visibleMatchPaths = collectionView.indexPathsForVisibleItems.filter {
            if case .match = dataSource.itemIdentifier(for: $0) { return true }
            return false
        }
        collectionView.reconfigureItems(at: visibleMatchPaths)
    }

    // MARK: UICollectionView Delegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard case .match(let match) = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.matchSelected(match)
    }

    // MARK: - Public Methods

    func updateWithQuery(query: MatchQueryOptions) {
        self.query = query
        favoriteTeamKeys = favoritesStore.favoriteTeamKeys()

        updateInterface()
        applyMatches(allMatches)
    }

    // MARK: - Interface Methods

    @objc func showFilter(_ sender: UIBarButtonItem) {
        delegate?.showFilter()
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool {
        if !query.filter.isDefault { return false }
        return allMatches.isEmpty
    }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let key = self.state.key
            async let matchesTask = self.dependencies.api.eventMatches(key: key)
            async let alliancesTask: [EliminationAlliance]?? = {
                try? await self.dependencies.api.eventAlliances(key: key)
            }()
            async let eventTask: Event? = {
                try? await self.dependencies.api.event(key: key)
            }()
            self.allMatches = try await matchesTask
            if let alliancesResult = await alliancesTask {
                self.allianceLookup = alliancesResult.map(AllianceLookup.init)
            }
            if let event = await eventTask {
                self.state = .event(event)
            }
            self.applyMatches(self.allMatches)
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        if query.isDefault {
            return "No matches for event"
        } else {
            return "No matches matching filter options"
        }
    }
}

private extension Array where Element == Match {
    func filter(for teamKey: String?, favoriteTeamKeys: [String]?) -> [Match] {
        var results = self
        if let teamKey {
            results = results.filter { $0.allTeamKeys.contains(teamKey) }
        }
        if let favoriteTeamKeys, !favoriteTeamKeys.isEmpty {
            let favSet = Set(favoriteTeamKeys)
            results = results.filter { match in
                match.allTeamKeys.contains(where: favSet.contains)
            }
        }
        return results
    }

    func sorted(ascending: Bool) -> [Match] {
        sorted { lhs, rhs in
            if lhs.compLevelSortOrder != rhs.compLevelSortOrder {
                return ascending
                    ? lhs.compLevelSortOrder < rhs.compLevelSortOrder
                    : lhs.compLevelSortOrder > rhs.compLevelSortOrder
            }
            if lhs.setNumber != rhs.setNumber {
                return ascending ? lhs.setNumber < rhs.setNumber : lhs.setNumber > rhs.setNumber
            }
            return ascending ? lhs.matchNumber < rhs.matchNumber : lhs.matchNumber > rhs.matchNumber
        }
    }
}

protocol MatchesViewControllerQueryable: ContainerViewController, MatchQueryOptionsDelegate {
    var myTBA: any MyTBAProtocol { get }
    var matchesViewController: MatchesViewController { get }

    func showFilter()
}

extension MatchesViewControllerQueryable {

    func showFilter() {
        let queryViewController = MatchQueryOptionsViewController(
            query: matchesViewController.query,
            dependencies: dependencies
        )
        queryViewController.delegate = self

        let nav = UINavigationController(rootViewController: queryViewController)
        nav.modalPresentationStyle = .formSheet

        navigationController?.present(nav, animated: true, completion: nil)
    }

    func updateQuery(query: MatchQueryOptions) {
        matchesViewController.updateWithQuery(query: query)
    }

}
