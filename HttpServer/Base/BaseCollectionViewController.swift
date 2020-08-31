//
//  BaseCollectionViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class BaseCollectionViewController: BaseViewController, Refreshable {
    @IBOutlet weak var collectionView: UICollectionView!

    var pageIndex: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// collection列表此方法无效，请使用`request(action:)`方法
    final override func request() {
    }

    func request(action: RefreshAction) {
    }
}
