//
//  Server.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import RxSwift

class Server {
    static private let server = HttpServer.share

    static func getUserInfo(id: Int, callback: ObjectObserver<User>) {
        server
            .request(api: UserApi.info(id: id), mapHandler: callback.mapObject())
            .subscribe(callback)
            .disposed(by: callback.disposeBag)
    }

    static func getScore(numId: Int, proId: Int, callback: ObjectObserver<Score>) {
        server
            .request(api: ScoreApi.getByUser(numId: numId, proId: proId), mapHandler: callback.mapObject())
            .subscribe(callback)
            .disposed(by: callback.disposeBag)
    }

    static func login(id: Int, callback: LoginObserver) {
        server
            .request(api: UserApi.info(id: id), mapHandler: callback.mapUser())
            .flatMap { (user) -> Observable<Login> in
                return server
                    .request(api: ScoreApi.getByUser(numId: user.numId, proId: user.provinceId), mapHandler: callback.mapScore())
                    .map { (score) -> Login in
                        return Login(user: user, score: score)
                    }
            }.subscribe(callback).disposed(by: callback.disposeBag)
    }

    static func zipLogin(id: Int, proId: Int, callback: LoginObserver) {
        let userRequest = server.request(api: UserApi.info(id: id), mapHandler: callback.mapUser())
        let scoreRequest = server.request(api: ScoreApi.getByUser(numId: id, proId: proId), mapHandler: callback.mapScore())
        Observable<Login>
            .zip(userRequest, scoreRequest, resultSelector: callback.mapLogin())
            .subscribe(callback)
            .disposed(by: callback.disposeBag)
    }
}

