//
//  ZipViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import RxSwift

class ZipViewController: UIViewController {
    let disposeBag = DisposeBag()

    lazy var observer = LoginObserver(disposeBag: disposeBag) { [unowned self] (result) in
        self.resultHandler(result)
    }

    deinit {
        print("ZipViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Server.zipLogin(id: 14077053, proId: 842, callback: observer)
        print("\(view.hashValue)")
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
