//
//  CollectionListViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

let ScreenW = UIScreen.main.bounds.width

class CollectionListViewController: BaseCollectionViewController {
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    private var rows: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.itemSize = CGSize(width: ScreenW, height: 55)
        addRefreshHeader()
        addRefreshFooter()
        loadData()
//        collectionView.reloadDataAndCheckEmpty()
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
            self?.collectionView.reloadDataAndCheckEmpty()
            self?.collectionView.endRefresh(action, isNotData: number < size)
        }
    }
}

extension CollectionListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionListCell", for: indexPath) as! CollectionViewCell
        cell.label.text = "cellForRowAt: \(indexPath.item)"
        return cell
    }
}

