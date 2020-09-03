//
//  HttpServer.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya
import RxSwift
import ObjectMapper

struct EGHttpError: Error {
    var code: Int
    var message: String

    var localizedDescription: String {
        return "code: \(code)  message: \(message)"
    }
}

extension EGHttpError {
    static let jsonError = EGHttpError(code: 1001, message: "数据转换失败")
}

class LoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        print("\n")
        print("------------------- 开始请求 -------------------")
        print("地址: ", target.baseURL.absoluteString + target.path)
        print("参数: ", target.task.parameters)
        print("类型: ", target.method)
        print("------------------- 开始请求 -------------------")
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let respose):
            let data = try? respose.mapString()
            print("\n")
            print("------------------- 开始结束 -------------------")
            print("地址: ", respose.request?.url?.absoluteString ?? "无")
            print("参数: ", target.task.parameters)
            print("类型: ", target.method)
            print("数据: ", data ?? "无")
            print("------------------- 开始结束 -------------------")
        case .failure(let error):
            print("LoggerPlugin", error)
        }
    }
}

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
    /// 开始加载动画
    ///
    /// - Parameter block: 传入执行开始动画的闭包
    /// - Returns: 返回 HttpServer 对象
    func startLoading(_ block: (() -> Void)?) -> HttpServer {
        block?()
        return self
    }

    private func sendRequest<Map, Element>(api: TargetType, map: Map) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        return provider
            .rx
            .request(MultiTarget(api))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .mapString()
            .map(map.mapObject())
    }

    func request<Map, Element>(api: TargetType & MoyaAddable, map: Map) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        return toObservable(sendRequest(api: api, map: map), strategy: api.policy.strategy, map: map)
    }

    func toObservable<Map, Element>(_ observable: Observable<Element>, strategy: BaseStrategy, map: Map) -> Observable<Element> where Map: MapHandler, Element == Map.Element {
        return strategy.execute(rxCache, handler: handler, map: map, observable: observable)
    }

//    func newRequest<Oberver, Element>(api: TargetType & MoyaAddable, oberver: Oberver) -> Observable<Element> where Oberver: AppObserverType, Oberver.Element == Element {
//        return newToObservable(request(api: api), strategy: api.policy.strategy, oberver: oberver)
//    }
//
//    func newToObservable<Oberver, Element>(_ observable: Observable<Response>, strategy: BaseStrategy, oberver: Oberver) -> Observable<Element> where Oberver: AppObserverType, Oberver.Element == Element {
//        return strategy.execute(rxCache, handler: handler, observable: observable).map(oberver.mapObject())
//    }
}

class ApiException {
    static func handleException(_ error: Error) -> HttpError {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let reponse):
                if reponse.statusCode == 408 {
                    return HttpError.timeout
                } else if reponse.statusCode == 401 {
                    return HttpError.noAuthority
                } else {
                    return HttpError.noNetwork
                }
            case .stringMapping, .jsonMapping, .imageMapping, .objectMapping:
                return HttpError.dataMapping
            case let .underlying(error, _):
                return HttpError.message(error.localizedDescription)
            default:
                return HttpError.requestMapping
            }
        } else if let httpError = error as? HttpError {
            return httpError
        } else {
            return .unknown
        }
    }
}
