//
//  UITableView+Refresh.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import MJRefresh

extension UITableView {
    func addRefreshHeader(useing block: @escaping () -> Void) {
        mj_header = MJRefreshNormalHeader {
            block()
        }
    }

    func addRefreshFooter(useing block: @escaping () -> Void) {
        let footer = MJRefreshAutoNormalFooter {
            block()
        }
        footer.isHidden = true
        mj_footer = footer
    }

    func addRefreshHeader(target: Any, action: Selector) {
        mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    }

    func addRefreshFooter(target: Any, action: Selector) {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        footer.isHidden = true
        mj_footer = footer
    }

    func endRefresh(_ action: RefreshAction, isNotData: Bool) {
        switch action {
        case .load:
            endRefreshHeader(isNotData: isNotData)
        case .more:
            endRefreshFooter(isNotData: isNotData)
        }
    }

    private func endRefreshHeader(isNotData: Bool) {
        mj_header?.endRefreshing()
        if !isNotData && mj_footer != nil {
            mj_footer?.isHidden = false
            mj_footer?.resetNoMoreData()
        } else if mj_footer != nil {
            mj_footer?.isHidden = true
        }
    }

    private func endRefreshFooter(isNotData: Bool) {
        if isNotData {
            mj_footer?.endRefreshingWithNoMoreData()
        } else {
            mj_footer?.endRefreshing()
        }
    }

    /// 重新加载数据并检查数据是否为空
    func reloadDataAndCheckEmpty(type: CheckType = .row) {
        reloadData()
        let isEmpty = isEmptyData(type: type)
        print(isEmpty)
        showEmpty(isEmpty)
    }

    private func isEmptyData(type: CheckType) -> Bool {
        switch type {
        case .section:
            return numberOfSections == 0
        case .row:
            return numberOfSections == 1 && numberOfRows(inSection: 0) == 0
        }
    }

    enum CheckType {
        case section
        case row
    }
}
