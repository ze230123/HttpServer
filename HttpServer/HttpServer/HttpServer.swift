//
//  HttpServer.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya
import RxSwift

let timeoutRequestClosure = { (endpoint: Endpoint, closure: @escaping MoyaProvider.RequestResultClosure) in
    do {
        var urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 5
        closure(.success(urlRequest))
    } catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
}

private var plugins: [PluginType] = [LoggerPlugin()]
private let provider = MoyaProvider<MultiTarget>(requestClosure: timeoutRequestClosure, callbackQueue: .main, plugins: plugins)

/// 网络服务单例（添加加载动画使用）
class HttpServer {
    static let shared = HttpServer()

    private let handler = RequestFrequencyHandler()

    private let rxCache: RxCache
    private let scheduler: SchedulerType

    private init() {
        print("网络初始化")
        scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default)
        rxCache = RxCache(scheduler: scheduler)
    }
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
            .observeOn(scheduler)
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

extension ObservableType {
    public func myDebug(identifier: String) -> Observable<Self.Element> {
       return Observable.create { observer in
           print("subscribed \(identifier)")
           let subscription = self.subscribe { e in
               print("event \(identifier)  \(e)")
               switch e {
               case .next(let value):
                   observer.on(.next(value))

               case .error(let error):
                   observer.on(.error(error))

               case .completed:
                   observer.on(.completed)
               }
           }
           return Disposables.create {
                  print("disposing \(identifier)")
                  subscription.dispose()
           }
       }
   }
}


extension HttpServer {
    func initServer() {
        _ = request(api: ConfigApi.cache, map: ObjectMap<AppConfig>()).myDebug(identifier: "cache mode")
            .map { $0.settingsJson }
            .compactMap { try? ObjectMap<Config>().mapObject($0).result }
            .subscribe(onNext: { (item) in
                print("缓存模式", item)
                AppConstant.CacheMode.update(item)
            }, onError: { (_) in
                print("缓存模式", "本地")
                AppConstant.CacheMode.updateFromDefaults()
            })
    }
}

import ObjectMapper

struct Config: Mappable {
    var college: Int = 0
    var major: Int = 0
    var pcl: Int = 0
    var other: Int = 0

    init() {}
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        college <- map["College"]
        major   <- map["Major"]
        pcl     <- map["PCL"]
        other   <- map["Other"]
    }
}
