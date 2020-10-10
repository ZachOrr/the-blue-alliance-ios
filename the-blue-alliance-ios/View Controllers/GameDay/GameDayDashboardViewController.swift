import CoreData
import Foundation
import TBAKit
import UIKit

class GameDayNavigationController: UINavigationController {}

class GameDayDashboardViewController: TBACollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionViewDataSource: CollectionViewDataSource<Section, Item>!

    private enum Section: Int {
        case regions, specialWebcasts, region
    }

    private struct Region: Equatable, Hashable {
        let name: String
        let webcastCount: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        static func == (lhs: Region, rhs: Region) -> Bool {
            return lhs.name == rhs.name
        }
    }

    private enum Item: Hashable {
        case region(Region)
        case webcast(GameDaySpecialEvent)
        case regionWebcast(Region, GameDaySpecialEvent)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .region(let region):
                hasher.combine(region)
            case .webcast(let webcast):
                hasher.combine(webcast.channel)
            case .regionWebcast(let region, let webcast):
                hasher.combine(region)
                hasher.combine(webcast.channel)
            }
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.region(let lhsRegion), .region(let rhsRegion)):
                return lhsRegion == rhsRegion
            case (.webcast(let lhsWebcast), .webcast(let rhsWebcast)):
                return lhsWebcast.channel == rhsWebcast.channel
            default:
                return false
            }
        }
    }

    override init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // TODO: We should be able to move this somewhere else and DRY this code
        title = RootType.gameDay.title
        tabBarItem.image = RootType.gameDay.icon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        */

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)

        collectionView.registerReusableSupplementaryView(elementKind: String(describing: GameDayHeaderView.self), GameDayHeaderView.self)
        collectionView.registerReusableCell(GameDayRegionCollectionViewCell.self)
        collectionView.registerReusableCell(GameDayWebcastCollectionViewCell.self)
        collectionView.collectionViewLayout = createLayout()
        collectionView.alwaysBounceVertical = true

        configureDataSource()
        applyInitialSnapshots()
    }

    static private func layoutForEnvironment(layoutEnvironment: NSCollectionLayoutEnvironment, vertical: NSCollectionLayoutSection, horizontal: NSCollectionLayoutSection) -> NSCollectionLayoutSection {
        if layoutEnvironment.traitCollection.userInterfaceIdiom == .phone {
            if layoutEnvironment.traitCollection.verticalSizeClass == .regular {
                return vertical
            }
            return horizontal
        } else if layoutEnvironment.traitCollection.userInterfaceIdiom == .pad {
            if layoutEnvironment.container.contentSize.width < 700 {
                return vertical
            }
            return horizontal
        }
        return horizontal
    }

    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }

            let horizontalSpacing: CGFloat = 16.0
            let verticalSpacing: CGFloat = 8.0
            let itemSpacing: CGFloat = 8.0

            let section: NSCollectionLayoutSection = {
                switch sectionKind {
                case .regions:
                    // TODO: 2/3 is too big on iPad, but looks great on iPhone
                    let estimatedWidth = NSCollectionLayoutDimension.fractionalWidth(2/3)
                    let estimatedHeight = NSCollectionLayoutDimension.estimated(50)

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: estimatedWidth, heightDimension: estimatedHeight)
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuous
                    section.interGroupSpacing = verticalSpacing
                    section.contentInsets = NSDirectionalEdgeInsets(top: verticalSpacing, leading: horizontalSpacing, bottom: verticalSpacing, trailing: horizontalSpacing)
                    return section
                case .featuredSpecialWebcasts:
                    let vertical: NSCollectionLayoutSection = {
                        let estimatedWidth = NSCollectionLayoutDimension.fractionalWidth(1.0)
                        let estimatedHeight = NSCollectionLayoutDimension.estimated(200)

                        let featuredItemSize = NSCollectionLayoutSize(widthDimension: estimatedWidth,
                                                                      heightDimension: estimatedHeight)
                        let featuredItem = NSCollectionLayoutItem(layoutSize: featuredItemSize)

                        let unfeaturedItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                                        heightDimension: estimatedHeight)
                        let unfeaturedItem = NSCollectionLayoutItem(layoutSize: unfeaturedItemSize)

                        let unfeaturedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                         heightDimension: estimatedHeight)
                        let unfeaturedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: unfeaturedGroupSize, subitem: unfeaturedItem, count: 2)
                        unfeaturedGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)

                        let groupSize = NSCollectionLayoutSize(widthDimension: estimatedWidth, heightDimension: NSCollectionLayoutDimension.estimated(400))
                        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [featuredItem, unfeaturedGroup])
                        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)

                        let section = NSCollectionLayoutSection(group: group)
                        // verticalSpacing / 2 so this section appears connected to the previous section
                        section.contentInsets = NSDirectionalEdgeInsets(top: verticalSpacing, leading: horizontalSpacing, bottom: verticalSpacing / 2, trailing: horizontalSpacing)
                        section.interGroupSpacing = verticalSpacing
                        return section
                    }()

                    let horizontal: NSCollectionLayoutSection = {
                        let itemWidth = layoutEnvironment.container.contentSize.width / 2
                        let fullPadding = (horizontalSpacing * 2) + itemSpacing
                        let itemPadding = (fullPadding / 2)

                        let width = NSCollectionLayoutDimension.absolute(itemWidth - itemPadding)
                        let estimatedHeight = NSCollectionLayoutDimension.estimated(400)

                        let featuredItemSize = NSCollectionLayoutSize(widthDimension: width,
                                                                      heightDimension: estimatedHeight)
                        let featuredItem = NSCollectionLayoutItem(layoutSize: featuredItemSize)



                        // Unfeatured sub group is 2 webcasts
                        let unfeaturedSubItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                                           heightDimension: estimatedHeight)
                        let unfeaturedSubItem = NSCollectionLayoutItem(layoutSize: unfeaturedSubItemSize)
                        let unfeaturedSubGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                            heightDimension: estimatedHeight)
                        let unfeaturedSubGroup = NSCollectionLayoutGroup.horizontal(layoutSize: unfeaturedSubGroupSize, subitem: unfeaturedSubItem, count: 2)



                        // Unfeatured section is 2 rows of 2 webcasts each
                        let unfeaturedGroupSize = NSCollectionLayoutSize(widthDimension: width,
                                                                         heightDimension: estimatedHeight)
                        let unfeaturedGroup = NSCollectionLayoutGroup.vertical(layoutSize: unfeaturedGroupSize, subitem: unfeaturedSubGroup, count: 2)
                        unfeaturedGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)



                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                               heightDimension: estimatedHeight)
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [featuredItem, unfeaturedGroup])
                        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)

                        let section = NSCollectionLayoutSection(group: group)
                        // verticalSpacing / 2 so this section appears connected to the previous section
                        section.contentInsets = NSDirectionalEdgeInsets(top: verticalSpacing, leading: horizontalSpacing, bottom: verticalSpacing / 2, trailing: horizontalSpacing)
                        section.interGroupSpacing = verticalSpacing
                        return section
                    }()

                    return GameDayDashboardViewController.layoutForEnvironment(layoutEnvironment: layoutEnvironment, vertical: vertical, horizontal: horizontal)
                case .specialWebcasts, .region:
                    let widthForRowCount: ((CGFloat) -> CGFloat) = { rowCount in
                        let itemWidth = layoutEnvironment.container.contentSize.width / rowCount
                        let fullPadding = (horizontalSpacing * 2) + (itemSpacing * (rowCount - 1))
                        let itemPadding = (fullPadding / rowCount)
                        return itemWidth - itemPadding
                    }

                    // 2 across in vertical
                    let vertical: NSCollectionLayoutSection = {
                        let estimatedHeight = NSCollectionLayoutDimension.estimated(200)

                        /*
                        let rowCount: CGFloat = 2
                        let estimatedWidth = NSCollectionLayoutDimension.absolute(widthForRowCount(rowCount) - 8)
                        let estimatedHeight = NSCollectionLayoutDimension.estimated(200)

                        let itemSize = NSCollectionLayoutSize(widthDimension: estimatedWidth,
                                                              heightDimension: estimatedHeight)
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)

                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.estimated(400))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)
                        */

                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48),
                                                              heightDimension: estimatedHeight)
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)

                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                               heightDimension: estimatedHeight)
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)

                        let section = NSCollectionLayoutSection(group: group)
                        // verticalSpacing / 2 so this section appears connected to the previous section
                        section.contentInsets = NSDirectionalEdgeInsets(top: verticalSpacing, leading: horizontalSpacing, bottom: verticalSpacing / 2, trailing: horizontalSpacing)
                        section.interGroupSpacing = verticalSpacing
                        return section
                    }()

                    // 4 across in horizontal
                    let horizontal: NSCollectionLayoutSection = {
                        let rowCount: CGFloat = 4
                        let estimatedWidth = NSCollectionLayoutDimension.absolute(widthForRowCount(rowCount))
                        let estimatedHeight = NSCollectionLayoutDimension.estimated(200)

                        let itemSize = NSCollectionLayoutSize(widthDimension: estimatedWidth,
                                                              heightDimension: estimatedHeight)
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)

                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.estimated(400))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemSpacing)

                        let section = NSCollectionLayoutSection(group: group)
                        // verticalSpacing / 2 so this section appears connected to the previous section
                        section.contentInsets = NSDirectionalEdgeInsets(top: verticalSpacing / 2, leading: horizontalSpacing, bottom: verticalSpacing, trailing: horizontalSpacing)
                        section.interGroupSpacing = verticalSpacing
                        return section
                    }()

                    return GameDayDashboardViewController.layoutForEnvironment(layoutEnvironment: layoutEnvironment, vertical: vertical, horizontal: horizontal)
                }
            }()

            // Add a header, if necessary
            if sectionKind == .featuredSpecialWebcasts || sectionKind == .region {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: String(describing: GameDayHeaderView.self), alignment: .top)]
            }

            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .region(let region):
                let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as GameDayRegionCollectionViewCell
                cell.viewModel = GameDayRegionViewModel(name: region.name, webcastCount: 4) // TODO: Fix this I guess?
                return cell
            case .webcast(let webcast):
                /*
                let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as GameDayWebcastCollectionViewCell
                cell.viewModel = GameDayWebcastCellViewModel(title: webcast.title, name: webcast.name, channel: webcast.channel, viewerCount: 50, thumbnail: webcast.thumbnail)
                return cell
                */
                let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as BasicCollectionViewCell
                cell.backgroundColor = .random()
                return cell
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let section = Section(rawValue: indexPath.section) else {
                return nil
            }
            let headerView: GameDayHeaderView = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath) as GameDayHeaderView
            if section == .featuredSpecialWebcasts {
                headerView.title = "Special Webcasts"
            } else if section == .region {
                headerView.title = "FIRST In Michigan"
            }
            return headerView
        }
        self.collectionViewDataSource = CollectionViewDataSource(dataSource: dataSource)
        // self.collectionViewDataSource.delegate = self
    }

    private func applyInitialSnapshots() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        let mi = Section.region(Region(name: "FIRST In Michigan", webcastCount: 4))
        snapshot.appendSections([.regions, .specialWebcasts, mi])
        snapshot.appendItems([
            .region(Region(name: "Regionals", webcastCount: 12)),
            .region(Region(name: "FIRST In Michigan ", webcastCount: 10)),
            .region(Region(name: "FIRST Chesapeake ", webcastCount: 5)),
            .region(Region(name: "FIRST Indiana Robotics ", webcastCount: 2)),
            .region(Region(name: "FIRST In Texas ", webcastCount: 2)),
            .region(Region(name: "FIRST Mid-Atlantic ", webcastCount: 2)),
            .region(Region(name: "FIRST North Carolina ", webcastCount: 1))
        ], toSection: .regions)

        snapshot.appendItems([
            .webcast(SpecialWebcast(keyName: "firstinspires",
                                    name: "FIRSTinspires",
                                    channel: "firstinspires",
                                    status: "online",
                                    type: "twitch",
                                    title: "2020 Global Innovation Award : Presented by Disney w/ Imagineers & Star Wars Galaxy's Edge!",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/db8c512c-eff8-4406-8e8f-07d70fea1be7-channel_offline_image-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "rsn",
                                    name: "RoboSports Network",
                                    channel: "robosportsnetwork",
                                    status: "online",
                                    type: "twitch",
                                    title: "RSN Spring Conferences - Presented by WPI - Day 5 - End of Bag Day Round Table",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/robosportsnetwork-channel_offline_image-e0778176508820e9-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "firstupdatesnow",
                                    name: "FIRST Updates Now",
                                    channel: "firstupdatesnow",
                                    status: "online",
                                    type: "twitch",
                                    title: "FUN Rocket League Tournament",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/b60b64d2-92c6-41d0-b579-f9524cafb5be-channel_offline_image-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "tba",
                                    name: "TBA GameDay",
                                    channel: "tbagameday",
                                    status: "online",
                                    type: "twitch",
                                    title: "Summer Hackathon 2k19! (React/Web)",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/tbagameday-channel_offline_image-ee057b50b56b5191-1920x1080.png")),
        ], toSection: .specialWebcasts)

        snapshot.appendItems([
            .webcast(SpecialWebcast(keyName: "FIRSTinMI01",
                                    name: "FIRSTinMI01",
                                    channel: "FIRSTinMI01",
                                    status: "online",
                                    type: "twitch",
                                    title: "FiM District - Macomb",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/3974eabb-6feb-452d-9b90-fa38476ec846-channel_offline_image-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "FIRSTinMI02",
                                    name: "FIRSTinMI02",
                                    channel: "FIRSTinMI02",
                                    status: "online",
                                    type: "twitch",
                                    title: "FiM District - Kettering #1",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/3974eabb-6feb-452d-9b90-fa38476ec846-channel_offline_image-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "FIRSTinMI03",
                                    name: "FIRSTinMI03",
                                    channel: "FIRSTinMI03",
                                    status: "online",
                                    type: "twitch",
                                    title: "FiM District - Southfield",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/3974eabb-6feb-452d-9b90-fa38476ec846-channel_offline_image-1920x1080.png")),
            .webcast(SpecialWebcast(keyName: "FIRSTinMI04",
                                    name: "FIRSTinMI04",
                                    channel: "FIRSTinMI04",
                                    status: "online",
                                    type: "twitch",
                                    title: "FiM District - Traverse City",
                                    thumbnail: "https://static-cdn.jtvnw.net/jtv_user_pictures/3974eabb-6feb-452d-9b90-fa38476ec846-channel_offline_image-1920x1080.png")),
        ], toSection: mi)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

struct SpecialWebcast: GameDaySpecialEvent {
    let keyName: String
    let name: String
    let channel: String
    let status: String
    let type: String
    let title: String
    let thumbnail: String
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}
