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
    /// 添加下拉刷新
    /// - Parameter block: 下拉刷新要执行的代码
    func addRefreshHeader(useing block: @escaping () -> Void) {
        mj_header = MJRefreshNormalHeader {
            block()
        }
    }

    /// 添加上拉加载
    /// - Parameter block: 上拉加载要执行的代码
    func addRefreshFooter(useing block: @escaping () -> Void) {
        let footer = MJRefreshAutoNormalFooter {
            block()
        }
        footer.isHidden = true
        mj_footer = footer
    }

    /// 添加下拉刷新
    func addRefreshHeader(target: Any, action: Selector) {
        mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    }

    /// 添加上拉加载
    func addRefreshFooter(target: Any, action: Selector) {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        footer.isHidden = true
        mj_footer = footer
    }

    /// 停止 `下拉刷新`/`上拉加载`
    /// - Parameters:
    ///   - action: `RefreshAction`刷新动作
    ///   - isNotData: 是否没有数据
    func endRefresh(_ action: RefreshAction, isNotData: Bool) {
        switch action {
        case .load:
            endRefreshHeader(isNotData: isNotData)
        case .more:
            endRefreshFooter(isNotData: isNotData)
        }
    }

    /// 停止下拉刷新
    ///
    /// 当数据不够一页时，隐藏`mj_footer`
    ///
    /// - Parameter isNotData: 是否没有数据
    private func endRefreshHeader(isNotData: Bool) {
        mj_header?.endRefreshing()
        if !isNotData && mj_footer != nil {
            mj_footer?.isHidden = false
            mj_footer?.resetNoMoreData()
        } else if mj_footer != nil {
            mj_footer?.isHidden = true
        }
    }

    /// 停止上拉加载
    ///
    /// 当数据不够一页时，`mj_footer`显示没有更多数据
    ///
    /// - Parameter isNotData: 是否没有数据
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
        showEmpty(isEmpty)
    }

    /// 判断是否没有数据
    /// - Parameter type: `CheckType`判断条件
    /// - Returns: `Bool`
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
