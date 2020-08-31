//
//  NewTableViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class NewTableViewController: BaseTableViewController {
    private var rows: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.updateEmptyTitle("列表为空")
        addRefreshHeader()
        addRefreshFooter()

        loadData()
    }

    override func request(action: RefreshAction) {
        view.showLoading(.image, isEnabled: rows == 0)

        let size: Int = 20

        TableList.request(second: 3) { [weak self] (number) in
            self?.view.stopLoading()
            if action == .load {
                self?.rows = 0
            }
            self?.rows += number
            self?.tableView.reloadDataAndCheckEmpty()
            self?.tableView.endRefresh(action, isNotData: number < size)
        }
    }
}

extension NewTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTableCell", for: indexPath)
        cell.textLabel?.text = "cellForRowAt: \(indexPath.row)"
        return cell
    }
}
