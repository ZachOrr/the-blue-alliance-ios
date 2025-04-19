//
//  SimpleContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/11/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import TBAUtils
import UIKit

typealias SimpleContainableViewController = UIViewController & SimpleRefreshable & Navigatable

class SimpleContainerViewController: UIViewController, Alertable {

    // MARK: - Public Properties

    @MainActor var navigationTitle: String? {
        didSet {
                navigationTitleLabel.text = navigationTitle
        }
    }

    @MainActor var navigationSubtitle: String? {
        didSet {
            navigationSubtitleLabel.text = navigationSubtitle
        }
    }

    @MainActor var rightBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            updateBarButtonItems()
        }
    }

    let dependencies: Dependencies

    var errorRecorder: ErrorRecorder {
        return dependencies.errorRecorder
    }
    var api: TBAAPI {
        return dependencies.api
    }

    // MARK: - Private View Elements

    private lazy var navigationStackView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubtitleLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        navigationStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationTitleTapped)))
        return navigationStackView
    }()
    private var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = SimpleContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return navigationTitleLabel
    }()
    private var navigationSubtitleLabel: UILabel = {
        let navigationSubtitleLabel = SimpleContainerViewController.createNavigationLabel()
        navigationSubtitleLabel.font = UIFont.systemFont(ofSize: 11)
        return navigationSubtitleLabel
    }()
    weak var navigationTitleDelegate: NavigationTitleDelegate?

    private let shouldShowSegmentedControl: Bool = false
    lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView(forAutoLayout: ())
        segmentedControlView.autoSetDimension(.height, toSize: 44.0)
        segmentedControlView.backgroundColor = UIColor.navigationBarTintColor
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    private var segmentedControl: UISegmentedControl

    private let containerView: UIView = UIView()
    private let viewControllers: [SimpleContainableViewController]
    private var rootStackView: UIStackView!

    private var offlineEventView: UIView = {
        let offlineEventLabel = UILabel(forAutoLayout: ())
        offlineEventLabel.text = "It looks like this event hasn't posted any results recently. It's possible that the internet connection at the event is down. The event's information might be out of date."
        offlineEventLabel.textColor = UIColor.dangerDarkRed
        offlineEventLabel.numberOfLines = 0
        offlineEventLabel.textAlignment = .center
        offlineEventLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)

        let offlineEventView = UIView(forAutoLayout: ())
        offlineEventView.addSubview(offlineEventLabel)
        offlineEventLabel.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        offlineEventView.backgroundColor = UIColor.dangerRed
        return offlineEventView
    }()

    init(viewControllers: [SimpleContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, dependencies: Dependencies) {
        self.viewControllers = viewControllers
        self.dependencies = dependencies

        self.navigationTitle = navigationTitle
        self.navigationSubtitle = navigationSubtitle

        segmentedControl = UISegmentedControl(items: segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        if let navigationTitle = navigationTitle, let navigationSubtitle = navigationSubtitle {
            navigationTitleLabel.text = navigationTitle
            navigationSubtitleLabel.text = navigationSubtitle
            navigationItem.titleView = navigationStackView
        }

        updateBarButtonItems()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove segmentedControl if we don't need one
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }

        rootStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        view.addSubview(rootStackView)

        // Add subviews to view hierarchy in reverse order, so first one is showing automatically
        for viewController in viewControllers.reversed() {
            addChild(viewController)
            containerView.addSubview(viewController.view)
            viewController.view.autoPinEdgesToSuperviewEdges()
            viewController.enableRefreshing()
        }

        rootStackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        rootStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSegmentedControlViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        // TODO: Consider only canceling if we're moving backwards or sideways in the view hierarchy, if we have
        // access to that information. Ex: Teams -> Team, we don't need to cancel the teams refresh
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/176
        if isMovingFromParent {
            cancelRefreshes()
        }
    }

    // MARK: - Public Methods

    public func switchedToIndex(_ index: Int) {}

    public func currentViewController() -> SimpleContainableViewController? {
        if viewControllers.count == 1, let viewController = viewControllers.first {
            return viewController
        } else if viewControllers.count > 0, viewControllers.count > segmentedControl.selectedSegmentIndex {
            return viewControllers[segmentedControl.selectedSegmentIndex]
        }
        return nil
    }

    public static func yearSubtitle(_ year: Int?) -> String {
        if let year = year {
            return "▾ \(year)"
        } else {
            return "▾ ----"
        }
    }

    @MainActor public func showOfflineEventMessage(shouldShow: Bool, animated: Bool = true) {
        if shouldShow {
            if !rootStackView.arrangedSubviews.contains(offlineEventView) {
                // Animate our down events view in
                if animated {
                    offlineEventView.isHidden = true
                }
                rootStackView.addArrangedSubview(offlineEventView)
                if animated {
                    // iOS animation timing magic number
                    UIView.animate(withDuration: 0.35) {
                        self.offlineEventView.isHidden = false
                    }
                }
            }
        } else {
            if animated {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.offlineEventView.isHidden = true
                    }, completion: { (_) in
                        self.rootStackView.removeArrangedSubview(self.offlineEventView)
                        if self.offlineEventView.superview != nil {
                            self.offlineEventView.removeFromSuperview()
                        }
                        self.offlineEventView.isHidden = false
                    })
                }
            } else {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    rootStackView.removeArrangedSubview(offlineEventView)
                }
                if offlineEventView.superview != nil {
                    self.offlineEventView.removeFromSuperview()
                }
            }
        }
    }

    // MARK: - Private Methods

    @MainActor @objc private func segmentedControlValueChanged() {
        updateSegmentedControlViews()
    }

    @MainActor private func updateSegmentedControlViews() {
        if let viewController = currentViewController() {
            show(view: viewController.view)
        }
        updateBarButtonItems()
    }

    @MainActor private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containedView) in viewControllers.compactMap({ $0.view }).enumerated() {
            let shouldHide = !(containedView == showView)
            if !shouldHide {
                let refreshViewController = viewControllers[index]

                // Reload our view on subsequent appears, since backing relationships
                // for objects might have changed while the view is in the background.
                // This can mean our view state falls out of sync with our data state while backgrounded.
                // Kickoff a reload to make sure our states match up.
                reloadViewController(refreshViewController)
                switchedIndex = index
                refreshViewController.refresh()
            }
            containedView.isHidden = shouldHide
        }
        switchedToIndex(switchedIndex)
    }

    @MainActor private func updateBarButtonItems() {
        var rightBarButtonItems: [UIBarButtonItem] = rightBarButtonItems
        if let viewController = currentViewController() {
            rightBarButtonItems.append(contentsOf: viewController.additionalRightBarButtonItems)
        }
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
    }

    @MainActor private func reloadViewController(_ viewController: UIViewController) {
        if let viewController = viewController as? TBAViewController {
            viewController.reloadData()
        } else if let viewController = viewController as? UITableViewController {
            viewController.tableView.reloadData()
        } else if let viewController = viewController as? UICollectionViewController {
            viewController.collectionView.reloadData()
        }
    }

    private func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }

    @objc private func navigationTitleTapped() {
        navigationTitleDelegate?.navigationTitleTapped()
    }

    // MARK: - Helper Methods

    private static func createNavigationLabel() -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }

}
