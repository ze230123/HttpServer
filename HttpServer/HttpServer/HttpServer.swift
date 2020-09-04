//
//  HttpServer.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya
import RxSwift

private var plugins: [PluginType] = [LoggerPlugin()]
private let provider = MoyaProvider<MultiTarget>(plugins: plugins)

/// 网络服务单例（添加加载动画使用）
class HttpServer {
    static let share = HttpServer()
    private let rxCache = RxCache()
    private let handler = RequestFrequencyHandler()

    init() {}
}

extension HttpServer {

    /// 发送请求
    /// - Parameters:
    ///   - api: 请求API
    ///   - map: 数据转换工具
    /// - Returns: 返回数据可观察对象
    private func sendRequest<Map, Element>(api: TargetType, map: Map) -> Observable<CacheResult<Element>> where Map: MapHandler, Element == Map.Element {
        return provider
            .rx
            .request(MultiTarget(api))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .mapString()
            .map(map.mapObject())
    }

    /// 请求api接口
    ///
    /// - Parameters:
    ///   - api: 请求api
    ///   - map: 数据转换工具
    /// - Returns: 返回数据可观察对象
    func request<Map, Element>(api: TargetType & MoyaAddable, map: Map) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        return toObservable(sendRequest(api: api, map: map), strategy: api.policy.strategy, map: map)
    }

    /// 处理请求的重复判断、缓存
    ///
    /// - Parameters:
    ///   - observable: 真实请求
    ///   - strategy: 缓存策略
    ///   - map: 数据转换工具
    /// - Returns: 返回数据可观察对象
    func toObservable<Map, Element>(_ observable: Observable<CacheResult<Element>>, strategy: BaseStrategy, map: Map) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        return strategy.execute(rxCache, handler: handler, map: map, observable: observable)
    }
}
