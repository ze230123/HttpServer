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
    lazy var newObserver = ObjectObserver<User>(disposeBag: DisposeBag(), observer: self)

    deinit {
        print("UserViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.updateEmptyTitle("哈哈哈哈哈")
        request()
    }

    override func request() {
        view.showLoading(.image)
        let id = 14077053
        Server.getUserInfo(id: id, observer: newObserver)
    }
}

extension UserViewController: ObserverHandler {
    typealias Element = User

    func resultHandler(_ result: Result<User, APIError>) {
        view.stopLoading()
        switch result {
        case .success(let user):
            print(user)
        case .failure(let error):
            view.showError(error, style: .hud, observer: self)
        }
    }
}
