//
//  SimpleRefreshable.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/10/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import UIKit

// Refreshable describes a class that has some data that can be refreshed from the server
@MainActor protocol SimpleRefreshable: AnyObject {
    var refreshTask: Task<Void, Never>? { get set }

    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    /**
     If the data source for the given view controller is empty - used to calculate if we should refresh.
     */
    var isDataSourceEmpty: Bool { get }

    func refresh()
    func endRefresh()

    func hideNoData()
    func noDataReload()
}

extension SimpleRefreshable {

    var isRefreshing: Bool {
        guard let refreshTask else {
            return false
        }
        // We're not refreshing if our operation queue is empty
        return !refreshTask.isCancelled
    }

    func endRefresh() {
        refreshTask?.cancel()
        refreshTask = nil

        updateRefresh()
    }

    func cancelRefresh() {
        guard let refreshTask else {
            return
        }
        refreshTask.cancel()
        self.refreshTask = nil

        updateRefresh()
    }

    @MainActor private func updateRefresh() {
        if self.isRefreshing {
            self.hideNoData()

            let refreshControlHeight = self.refreshControl?.frame.size.height ?? 0
            self.refreshView.setContentOffset(CGPoint(x: 0, y: -refreshControlHeight), animated: true)
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()

            self.noDataReload()
        }
    }

    @MainActor func enableRefreshing() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refresh")), for: .valueChanged)

        self.refreshControl = refreshControl
    }

    @MainActor func disableRefreshing() {
        refreshControl = nil
    }
}
