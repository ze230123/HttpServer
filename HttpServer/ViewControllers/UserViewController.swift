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
    let disposeBag = DisposeBag()

    lazy var observer = ObjectObserver<User>({ [unowned self] in self.resultHandler($0) })

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
//        let id = 14077136
        Server.getUserInfo(id: id, disposeBag: disposeBag, callback: observer)
    }

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

protocol HttpServerHandler {
    associatedtype Element
    func resultHandler(_ result: Result<Element, HttpError>)
}
