//
//  FaltMapViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/24.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import RxSwift

/// login观察者
///
/// 多个接口返回模型的聚合模型
class LoginObserver: Observer<Login> {
    let userMap = ObjectMap<User>()
    let scoreMap = ObjectMap<Score>()

    func mapLogin() -> (User, Score) -> Login {
        return { (user, score) in
            return Login(user: user, score: score)
        }
    }
}

class FaltMapViewController: BaseViewController {
    lazy var observer = LoginObserver(disposeBag: self.disposeBag, observer: self)

    deinit {
        print("FaltMapViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Server.login(id: 14077053, observer: observer)
//        Server.getScore(numId: 14077053, proId: 842, disposeBag: disposeBag, callback: observer)
//        Server.login(id: 14077053, disposeBag: disposeBag, callback: observer)
        print("\(view.hashValue)")
    }
}

extension FaltMapViewController: ObserverHandler {
    typealias Element = Login

    func resultHandler(_ result: Result<Login, APIError>) {
        switch result {
        case .success(let user):
            print(user)
        case .failure(let error):
            print(error)
        }
    }
}
