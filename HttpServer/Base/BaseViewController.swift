//
//  BaseViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController, ErrorHandlerObserverType {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    /// 网络请求、子类重写
    func request() {
    }

    func onReTry() {
        request()
    }
}
