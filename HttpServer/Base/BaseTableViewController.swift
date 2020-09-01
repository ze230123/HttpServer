//
//  BaseTableViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController, Refreshable {
    @IBOutlet var tableView: UITableView!
    var pageIndex: Int = 1

    /// 刷新行为
    private(set) var action: RefreshAction = .load

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// table列表此方法无效，请使用`request(action:)`方法
    final override func request() {
    }

    /// 将要调用网络请求
    ///
    /// `loadData()`、`moreData()`方法会调用`willRequest(action:)`
    /// 对`action`赋值、一遍在其他地方使用
    final func willRequest(action: RefreshAction) {
        self.action = action
        request(action: action)
    }

    /// 请求网络
    ///
    /// - Parameter action: 行为：加载/更多, 具体细节查看`RefreshAction`
    func request(action: RefreshAction) {
    }
}
