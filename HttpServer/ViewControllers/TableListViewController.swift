//
//  TableListViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class TableList {
    static func request(second: Double, handler: @escaping (Int) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            let row = Int.random(in: 19...20)
            DispatchQueue.main.async {
                handler(row)
            }
        }
    }
}

class TableListViewController: UITableViewController {

    private var rows: Int = 0

    private var pageIndex: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addRefreshHeader(target: self, action: #selector(loadData))
        loadData()
    }

    func request(action: RefreshAction) {
        view.showLoading(.image)

        let size: Int = 20

        TableList.request(second: 3) { [weak self] (number) in
            print("number", number)
            if action == .load {
                self?.rows = 0
            }
            self?.rows += number
            self?.tableView.reloadDataAndCheckEmpty()
            self?.tableView.endRefresh(action, isNotData: number < size)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableListCell", for: indexPath)
        cell.textLabel?.text = "cellForRowAt: \(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

extension TableListViewController {
    @objc func loadData() {
        pageIndex = 1
        request(action: .load)
    }

    @objc func moreData() {
        pageIndex += 1
        request(action: .more)
    }
}
