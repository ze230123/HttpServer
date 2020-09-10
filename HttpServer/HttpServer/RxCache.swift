//
//  RxCache.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import Security
import RxSwift
import Moya

/// Rx封装的缓存工具类
class RxCache {
    private let scheduler: SchedulerType

    init(scheduler: SchedulerType) {
        self.scheduler = scheduler
    }
    /// 读取缓存
    /// - Parameters:
    ///   - key: 缓存key
    ///   - map: 数据转换工具
    /// - Returns: 数据可观察对象
    func load<Map, Element>(_ key: String, map: Map) -> Observable<CacheResult<Element>> where Map: MapHandler, Element == Map.Element {
        let observable = Observable<String>.create { (observer) -> Disposable in
            if let cache = CacheCore.shared.cache(for: key) {
                observer.onNext(cache)
            } else {
                observer.onError(APIError(mode: .noCache))
            }
            return Disposables.create()
        }
        return observable.observeOn(scheduler).map(map.mapObject)
    }

    /// 保存数据
    /// - Parameters:
    ///   - value: 要缓存的数据
    ///   - key: 缓存key
    ///   - expiry: 过期时间
    ///   - map: 数据转换工具
    /// - Returns: 数据可观察对象
    func save<Map, Element>(_ value: CacheResult<Element>, key: String, expiry: Expiry, map: Map) -> Observable<CacheResult<Element>> where Map: MapHandler, Element == Map.Element {
        if let cache = value.jsonString {
            CacheCore.shared.setCache(cache, key: key, expiry: expiry)
        }
        return .just(value)
    }
}
