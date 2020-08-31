//
//  EmptyViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

enum RefreshAction {
    case load
    case more
}

class Empty {
    static func request(second: Double, handler: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + second) {
            let isEmpty = Bool.random()
            DispatchQueue.main.async {
                handler(isEmpty)
            }
        }
    }
}

class EmptyViewController: UIViewController {
    deinit {
        print("EmptyViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let rigth = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
        navigationItem.rightBarButtonItem = rigth
    }

    func request(action: RefreshAction) {
        view.showLoading(.random())

        Empty.request(second: 3) { [weak self] (isEmpty) in
            print(isEmpty)
            self?.view.showEmpty(isEmpty)
        }
    }

    @objc func refreshAction() {
        request(action: .load)
    }
}
