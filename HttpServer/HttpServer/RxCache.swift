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
    func load(_ key: String) -> Observable<String?> {
        return Observable.just(CacheCore.shared.cache(for: key))
    }

    func save(_ value: String, key: String, expiry: Expiry) -> Observable<String> {
        CacheCore.shared.setCache(value, key: key, expiry: expiry)
        return Observable.just(value)
    }
}

/// 缓存策略基类
class BaseStrategy {
    fileprivate let config: CacheConfig

    init(config: CacheConfig) {
        self.config = config
    }

    /// 读取缓存数据
    ///
    /// 先在磁盘中查找缓存，如果没有找到则发送`HttpError.noCache`错误
    /// 如果`needEmpty`为true，则监听`catchError`返回`Observable.empty()`
    ///
    /// - Parameters:
    ///   - rxCache: 缓存工具类
    ///   - needEmpty: Bool类型，true：没找到缓存时返回Empty，false：正常返回
    /// - Returns: Observable<String>类型的可观察对象
    func loadCache(_ rxCache: RxCache, needEmpty: Bool) -> Observable<String> {
        var observable = rxCache.load(config.api + config.parameter).map { (value) -> String in
            guard let new = value else {
                throw HttpError.noCache
            }
            return new
        }
        if needEmpty {
            observable = observable.catchError({ (_) -> Observable<String> in
                return Observable.empty()
            })
        }
        return observable
    }

    func loadRemote(_ rxCache: RxCache, observable: Observable<Response>) -> Observable<String> {
        let key = config.key
        let expiry = config.expiry

        let obser = observable.flatMap { (response) -> Observable<String> in
            let result = try response.mapResultValue()
            return rxCache.save(result, key: key, expiry: expiry)
        }
        return obser
    }

    /// 执行操作
    /// - Parameters:
    ///   - rxCache: 缓存工具
    ///   - handler: 接口请求频率处理工具
    ///   - observable: 正常的请求
    /// - Returns: 返回经过缓存策略工具处理过的请求
    func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        fatalError()
    }
}

class NoCacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return Observable.error(HttpError.frequently)
        } else {
            return observable.map { (response) -> String in
                return try response.mapResultValue()
            }
        }
    }
}

/// 缓存策略：缓存、网络都会返回
///
/// 先读取缓存，不管有没有缓存都会请求网络
/// 等网络返回后，发现数据一样就不会返回，不同则会再次返回网络的数据
class CacheAndRemoteDistinctStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return Observable.concat(cache, remote).filter( { !$0.isEmpty } ).distinctUntilChanged { (str1, str2) -> Bool in
                print("对比str1: ", str1)
                print("对比str2: ", str2)
                print(str1 == str2)
                return str1 == str2
            }
        }
    }
}

/// 缓存策略：缓存优先
///
/// 先读取缓存，缓存不存在，在请求网络
/// 如果次数超出规定限制，直接读取缓存
class FirstCacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return cache.ifEmpty(switchTo: remote)
        }
    }
}

/// 缓存策略：网络优先
///
/// 先请求网络，网络请求失败，再加载缓存
/// 如果次数超出规定限制 直接读取缓存
class FirstRequestStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.api, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return remote.catchError( { _ in cache } )
        }
    }
}


extension Response {
    /// 取出返回数据中的`result`，在将其转换为string返回
    func mapResultValue() throws -> String {
        guard let json = try mapJSON() as? [String: Any],
         let result = json["result"] else {
            throw MoyaError.stringMapping(self)
        }
        guard JSONSerialization.isValidJSONObject(result) else {
            throw MoyaError.jsonMapping(self)
        }
        let data = try JSONSerialization.data(withJSONObject: result, options: [])
        return String(data: data, encoding: .utf8) ?? ""
    }
}
