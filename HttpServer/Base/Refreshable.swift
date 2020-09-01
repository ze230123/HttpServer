//
//  Refreshable.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

protocol Refreshable: class {
    var pageIndex: Int { get set }
    func loadData()
    func moreData()
}

extension Refreshable where Self: BaseTableViewController {
    func addRefreshHeader() {
        tableView.addRefreshHeader { [weak self] in
            self?.loadData()
        }
    }

    func addRefreshFooter() {
        tableView.addRefreshFooter { [weak self] in
            self?.moreData()
        }
    }

    func loadData() {
        pageIndex = 1
        willRequest(action: .load)
    }

    func moreData() {
        pageIndex += 1
        willRequest(action: .more)
    }
}

extension Refreshable where Self: BaseCollectionViewController {
    func addRefreshHeader() {
        collectionView.addRefreshHeader { [weak self] in
            self?.loadData()
        }
    }

    func addRefreshFooter() {
        collectionView.addRefreshFooter { [weak self] in
            self?.moreData()
        }
    }

    func loadData() {
        pageIndex = 1
        willRequest(action: .load)
    }

    func moreData() {
        pageIndex += 1
        willRequest(action: .more)
    }
}
