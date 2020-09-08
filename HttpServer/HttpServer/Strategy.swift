//
//  Strategy.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import RxSwift

/// 缓存策略基类
class BaseStrategy {
    fileprivate let config: CacheConfig

    init(config: CacheConfig) {
        self.config = config
    }

    /// 读取本地缓存
    ///
    /// 先在磁盘中查找缓存，如果没有找到则发送`HttpError.noCache`错误
    /// 如果`needEmpty`为true，则监听`catchError`返回`Observable.empty()`
    ///
    /// - Parameters:
    ///   - rxCache: 缓存工具类
    ///   - map: 数据转换工具
    ///   - needEmpty: Bool类型，true：没找到缓存时返回Empty，false：正常返回
    /// - Returns: 数据可观察对象
    func loadCache<Map, Element>(_ rxCache: RxCache, map: Map, needEmpty: Bool) -> Observable<CacheResult<Element>> where Map: MapHandler, Element == Map.Element {
        var observable = rxCache.load(config.key, map: map)
        if needEmpty {
            observable = observable.catchError({ (_) -> Observable<CacheResult<Element>> in
                return Observable.empty()
            })
        }
        return observable
    }

    /// 读取服务器数据
    ///
    /// 读取服务器数据并缓存到本地
    ///
    /// - Parameters:
    ///   - rxCache: 缓存工具类
    ///   - map: 数据转换工具
    ///   - observable: 真实请求的可观察对象
    /// - Returns: 数据可观察对象
    func loadRemote<Map, Element>(_ rxCache: RxCache, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<CacheResult<Element>> where Map: MapHandler, Element == Map.Element {
        let key = config.key
        let expiry = config.expiry

        let obser = observable.flatMap { (value) -> Observable<CacheResult<Element>> in
            return rxCache.save(value, key: key, expiry: expiry, map: map)
        }
        return obser
    }

    /// 执行操作
    /// - Parameters:
    ///   - rxCache: 缓存工具
    ///   - handler: 接口请求频率处理工具
    ///   - observable: 正常的请求
    /// - Returns: 返回经过缓存策略工具处理过的请求
    func execute<Map, Element>(_ rxCache: RxCache, handler: RequestFrequencyHandler, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        fatalError()
    }
}

class NoCacheStrategy: BaseStrategy {
    override func execute<Map, Element>(_ rxCache: RxCache, handler: RequestFrequencyHandler, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<Element> where Map : MapHandler, Element == Map.Element {
        if handler.invalid(api: config.api, parameter: config.parameters) {
            return Observable.error(APIError(mode: .overload))
        } else {
            return observable.map { $0.result }
        }
    }
}

/// 缓存策略：缓存、网络都会返回
///
/// 先读取缓存，不管有没有缓存都会请求网络
/// 等网络返回后，发现数据一样就不会返回，不同则会再次返回网络的数据
class CacheAndRemoteDistinctStrategy: BaseStrategy {
    override func execute<Map, Element>(_ rxCache: RxCache, handler: RequestFrequencyHandler, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<Element> where Map : MapHandler, Element == Map.Element {
        if handler.invalid(api: config.api, parameter: config.parameters) {
            return loadCache(rxCache, map: map, needEmpty: false).map { $0.result }
        } else {
            let cache = loadCache(rxCache, map: map, needEmpty: true)
            let remote = loadRemote(rxCache, map: map, observable: observable)
            return Observable.concat(cache, remote).distinctUntilChanged(map.mapString, comparer: ==).map { $0.result }
        }
    }
}

/// 缓存策略：缓存优先
///
/// 先读取缓存，缓存不存在，在请求网络
/// 如果次数超出规定限制，直接读取缓存
class FirstCacheStrategy: BaseStrategy {
    override func execute<Map, Element>(_ rxCache: RxCache, handler: RequestFrequencyHandler, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<Element> where Map : MapHandler, Element == Map.Element {
        if handler.invalid(api: config.api, parameter: config.parameters) {
            return loadCache(rxCache, map: map, needEmpty: false).map { $0.result }
        } else {
            let cache = loadCache(rxCache, map: map, needEmpty: true)
            let remote = loadRemote(rxCache, map: map, observable: observable)
            return cache.ifEmpty(switchTo: remote).map { $0.result }
        }
    }
}

/// 缓存策略：网络优先
///
/// 先请求网络，网络请求失败，再加载缓存
/// 如果次数超出规定限制 直接读取缓存
class FirstRequestStrategy: BaseStrategy {
    override func execute<Map, Element>(_ rxCache: RxCache, handler: RequestFrequencyHandler, map: Map, observable: Observable<CacheResult<Element>>) -> Observable<Element> where Map : MapHandler, Element == Map.Element {
        if handler.invalid(api: config.api, parameter: config.parameters) {
            return loadCache(rxCache, map: map, needEmpty: false).map { $0.result }
        } else {
            let cache = loadCache(rxCache, map: map, needEmpty: true).map { $0.result }
            let remote = loadRemote(rxCache, map: map, observable: observable).map { $0.result }
            return remote.catchError( { _ in cache } )
        }
    }
}
