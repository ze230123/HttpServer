//
//  BannerViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class BannerViewController: BaseViewController {
    @IBOutlet weak var bannerView: BannerView!

    lazy var observer = ObjectListObserver<Banners>(disposeBag: self.disposeBag, observer: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }

    override func request() {
        view.showLoading(.imageHud)
        Server.banner(parameter: BannerParameter.home, observer: observer)
    }
}

extension BannerViewController: ObserverHandler {
    typealias Element = [Banners]
    func resultHandler(_ result: Result<[Banners], APIError>) {
        view.stopLoading()
        switch result {
        case .success(let list):
            let images = list.map { $0.mobilePictureUrl }
            print("images: ", images)
            bannerView.setImages(images: images)
        case .failure(let error):
            view.showError(error)
        }
    }
}
