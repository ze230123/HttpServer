//
//  FaltMapViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/24.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import RxSwift

class FaltMapViewController: UIViewController {
    let disposeBag = DisposeBag()

    lazy var observer = LoginObserver({ [unowned self] in self.resultHandler($0) })

    deinit {
        print("FaltMapViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        Server.getScore(numId: 14077053, proId: 842, disposeBag: disposeBag, callback: observer)
        Server.login(id: 14077053, disposeBag: disposeBag, callback: observer)
    }

    func resultHandler(_ result: Result<Login, HttpError>) {
        switch result {
        case .success(let user):
            print(user)
        case .failure(let error):
            print(error)
        }
    }
}

