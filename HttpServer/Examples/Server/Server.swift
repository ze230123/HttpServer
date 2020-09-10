//
//  Server.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    func eg_subscribe<Observer>(_ observer: Observer) -> Disposable where Element == Observer.Element, Observer : ObserverType {
        return observeOn(MainScheduler.asyncInstance).subscribe(observer)
    }
}

class Server {
    static private let server = HttpServer.share

    /// 正常请求 获取用户信息
    /// - Parameters:
    ///   - id: 用户ID
    ///   - callback: 回调对象
    static func getUserInfo(id: Int, observer: ObjectObserver<User>) {
        server
            .request(api: UserApi.info(id: id), map: observer.map)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 正常请求，获取成绩
    /// - Parameters:
    ///   - numId: 用户ID
    ///   - proId: 省份ID
    ///   - callback: 回调对象
    static func getScore(numId: Int, proId: Int, observer: ObjectObserver<Score>) {
        server
            .request(api: ScoreApi.getByUser(numId: numId, proId: proId), map: observer.map)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 依赖请求，及后一个请求需要前一个请求的结果
    /// - Parameters:
    ///   - id: 用户ID
    ///   - callback: 回调对象
    static func login(id: Int, observer: LoginObserver) {
        server
            .request(api: UserApi.info(id: id), map: observer.userMap)
            .flatMap { (user) -> Observable<Login> in
                return server
                    .request(api: ScoreApi.getByUser(numId: user.numId, proId: user.provinceId), map: observer.scoreMap)
                    .map { (score) -> Login in
                        return Login(user: user, score: score)
                    }
            }
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 同时请求
    /// - Parameters:
    ///   - id: 用户ID
    ///   - proId: 省份ID
    ///   - callback: 回调对象
    static func zipLogin(id: Int, proId: Int, observer: LoginObserver) {
        let userRequest = server.request(api: UserApi.info(id: id), map: observer.userMap)
        let scoreRequest = server.request(api: ScoreApi.getByUser(numId: id, proId: proId), map: observer.scoreMap)
        Observable<Login>
            .zip(userRequest, scoreRequest, resultSelector: observer.mapLogin())
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .observeOn(MainScheduler.instance)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
//        let userRequest = server.request(api: UserApi.info(id: id), mapHandler: callback.mapUser())
//        let scoreRequest = server.request(api: ScoreApi.getByUser(numId: id, proId: proId), mapHandler: callback.mapScore())
//        Observable<Login>
//            .zip(userRequest, scoreRequest, resultSelector: callback.mapLogin())
//            .subscribe(callback)
//            .disposed(by: callback.disposeBag)
    }

    /// 获取全部院校数据
    /// - Parameters:
    ///   - parameter: 接口参数
    ///   - observer: 回调对象
    static func collegeAllList(parameter: AllCollegeParameter, observer: AllCollegeObserver) {
        server
            .request(api: CollegeApi.all(parameter), map: observer.map)
            .map(observer.mapList())
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .observeOn(MainScheduler.instance)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 关注院校
    /// - Parameters:
    ///   - id: 院校ID
    ///   - isLike: true：已关注，false: 未关注
    ///   - observer: 回调对象
    static func likeCollege(
        id: Int,
        name: String,
        isLike: Bool,
        disposeBag: DisposeBag,
        handler: @escaping VoidObserver.EventHandler)
    {
        let observer = VoidObserver(disposeBag: disposeBag) { (result) in
            handler(result)
        }

        var api: CollegeApi

        if isLike {
            api = .delete(id: id, name: name)
        } else {
            api = .insert(id: id, name: name)
        }

        server
            .request(api: api, map: observer.map)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .observeOn(MainScheduler.instance)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    static func banner(parameter: BannerParameter, observer: ObjectListObserver<Banners>) {
        server
            .request(api: CollegeApi.banner(parameter), map: observer.map)
            .eg_subscribe(observer)
            .disposed(by: observer.disposeBag)
    }
}
