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

    lazy var observer = LoginObserver({ [unowned self] in self.resultHandler($0) })

    deinit {
        print("ZipViewController_deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Server.zipLogin(id: 14077053, proId: 842, disposeBag: disposeBag, callback: observer)
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
