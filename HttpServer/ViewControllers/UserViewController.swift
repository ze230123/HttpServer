//
//  UserViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/20.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import RxSwift


class UserViewController: BaseViewController {
    lazy var observer = ObjectObserver<User>.init(disposeBag: self.disposeBag) { [unowned self] (result) in
        self.resultHandler(result)
    }

    deinit {
        print("UserViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.updateEmptyTitle("哈哈哈哈哈")
        print("\(view.hashValue)")
        request()
    }

    override func request() {
        let id = 14077053
        Server.getUserInfo(id: id, callback: observer)
    }
}

extension UserViewController: HttpResultHandler {
    typealias Element = User

    func resultHandler(_ result: Result<User, HttpError>) {
        switch result {
        case .success(let user):
            print(user)
        case .failure(let error):
            print("userError: ", error)
        }
        view.showEmpty(true)
    }
}
