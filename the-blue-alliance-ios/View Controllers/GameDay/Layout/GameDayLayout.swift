import Foundation
import UIKit

enum GameDayLayout: CaseIterable {

    case single
    case dual
    case onePlusTwo
    case quad

    private static let fullLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    private static let halfHeightLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
    private static let halfWidthLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))

    var title: String {
        switch self {
        case .single:
            return "Single View"
        case .dual:
            return "Dual View"
        case .onePlusTwo:
            return "\"1 + 2\" View"
        case .quad:
            return "Quad View"
        }
    }

    var image: UIImage? {
        switch self {
        case .single:
            return UIImage(systemName: "rectangle.fill")
        case .dual:
            return UIImage(systemName: "square.split.2x1.fill")
        case .onePlusTwo:
            return UIImage(systemName: "rectangle.3.offgrid.fill") // Rotate?
        case .quad:
            return UIImage(systemName: "rectangle.grid.2x2.fill")
        }
    }

    var numberOfItems: Int {
        switch self {
        case .single:
            return 1
        case .dual:
            return 2
        case .onePlusTwo:
            return 3
        case .quad:
            return 4
        }
    }

    var collectionViewLayout: UICollectionViewLayout {
        switch self {
        case .single:
            return GameDayLayout.singleLayout()
        case .dual:
            return GameDayLayout.dualLayout()
        case .onePlusTwo:
            return GameDayLayout.onePlusTwoLayout()
        case .quad:
            return GameDayLayout.quadLayout()
        }
    }

    static var maxNumberOfItems: Int {
        return GameDayLayout.allCases.map { $0.numberOfItems }.max() ?? 0
    }

    static func layoutFor(_ count: Int) -> GameDayLayout {
        if count < 2 {
            return .single
        } else if count == 2 {
            return .dual
        } else if count == 3 {
            return .onePlusTwo
        }
        return .quad
    }

    /* Layout 0: full screen single video
     +------+------+
     |             |
     |      0      |
     |             |
     +------+------+
     */
    private static func singleLayout() -> UICollectionViewLayout {
        let layout = GameDayCollectionViewLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: GameDayLayout.fullLayoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.fullLayoutSize, subitems: [item])
            return NSCollectionLayoutSection(group: group)
        }
        return layout
    }

    /* Layout 1: two videos side-by-side
     Landscape
     +------+------+
     |      |      |
     |  0   |   1  |
     |      |      |
     +------+------+
     Portrait
     +-------------+
     |      0      |
     |-------------|
     |      1      |
     +-------------+
     */
    private static func dualLayout() -> UICollectionViewLayout {
        let layout = GameDayCollectionViewLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let group: NSCollectionLayoutGroup = {
                if layoutEnvironment.container.effectiveContentSize.width > layoutEnvironment.container.effectiveContentSize.height {
                    let item = NSCollectionLayoutItem(layoutSize: GameDayLayout.halfWidthLayoutSize)
                    return NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.fullLayoutSize, subitem: item, count: 2)
                }
                let item = NSCollectionLayoutItem(layoutSize: GameDayLayout.halfHeightLayoutSize)
                return NSCollectionLayoutGroup.vertical(layoutSize: GameDayLayout.fullLayoutSize, subitem: item, count: 2)
            }()
            return NSCollectionLayoutSection(group: group)
        }
        return layout
    }

    /* Layout 2
     Landscape
     +------+------+
     |      |   1  |
     |  0   |------|
     |      |   2  |
     +------+------+
     Portrait
     +-------------+
     |      0      |
     |-------------|
     |  1   |   2  |
     +-------------+
     */
    private static func onePlusTwoLayout() -> UICollectionViewLayout {
        let layout = GameDayCollectionViewLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let isWide = layoutEnvironment.container.effectiveContentSize.width > layoutEnvironment.container.effectiveContentSize.height
            let leadingItem: NSCollectionLayoutItem = {
                if isWide {
                    return NSCollectionLayoutItem(layoutSize: GameDayLayout.halfWidthLayoutSize)
                }
                return NSCollectionLayoutItem(layoutSize: GameDayLayout.halfHeightLayoutSize)
            }()

            let trailingItem: NSCollectionLayoutItem = {
                if isWide {
                    return NSCollectionLayoutItem(layoutSize: GameDayLayout.halfHeightLayoutSize)
                }
                return NSCollectionLayoutItem(layoutSize: GameDayLayout.halfWidthLayoutSize)
            }()
            let trailingGroup: NSCollectionLayoutGroup = {
                if isWide {
                    return NSCollectionLayoutGroup.vertical(layoutSize: GameDayLayout.halfWidthLayoutSize, subitem: trailingItem, count: 2)
                }
                return NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.halfHeightLayoutSize, subitem: trailingItem, count: 2)
            }()

            let group: NSCollectionLayoutGroup = {
                if isWide {
                    return NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.fullLayoutSize, subitems: [leadingItem, trailingGroup])
                }
                return NSCollectionLayoutGroup.vertical(layoutSize: GameDayLayout.fullLayoutSize, subitems: [leadingItem, trailingGroup])
            }()
            return NSCollectionLayoutSection(group: group)
        }
        return layout
    }

    /* Layout 3
     +------+------+
     |   0  |   1  |
     |------|------|
     |   2  |   3  |
     +------+------+
     */
    private static func quadLayout() -> UICollectionViewLayout {
        let layout = GameDayCollectionViewLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: GameDayLayout.halfWidthLayoutSize)

            let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.halfHeightLayoutSize, subitem: item, count: 2)
            let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: GameDayLayout.halfHeightLayoutSize, subitem: item, count: 2)

            return NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: GameDayLayout.fullLayoutSize, subitems: [topGroup, bottomGroup]))
        }
        return layout
    }

}

class GameDayCollectionViewLayout : UICollectionViewCompositionalLayout {

    public static let movingCellScale = CGFloat(1.125)
    public static let movingCellAlpha = CGFloat(0.7)

    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath as IndexPath, withTargetPosition: position)

        attributes.alpha = GameDayCollectionViewLayout.movingCellAlpha
        attributes.transform = CGAffineTransform(scaleX: GameDayCollectionViewLayout.movingCellScale, y: GameDayCollectionViewLayout.movingCellScale)

        return attributes
    }

}
