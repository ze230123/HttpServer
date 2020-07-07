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

extension ObservableType where Element == String {
    /// 新JSON转模型
    ///
    /// ResultModel 可根据需要替换
    func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<ResultModel<T>> {
        return map { (json) in
            guard let item = Mapper<ResultModel<T>>().map(JSONString: json) else {
                throw EGHttpError.jsonError
            }
            return item
        }
    }

//    /// JSON转模型数组
//    ///
//    /// ListModel 可根据需要替换
//    func mapList<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<ListModel<T>> {
//        return map { (response) in
//            return try response.mapObject(ListModel<T>.self, context: context)
//        }
//    }

//    /// JSON转String模型（var result: String）
//    ///
//    /// ResultModel 可根据需要替换
//    func mapStringModel() -> Observable<StringModel> {
//        return map { (response) in
//            return try response.mapObject(StringModel.self, context: nil)
//        }
//    }
}


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

private var plugins: [PluginType] = []
private let provider = MoyaProvider<MultiTarget>(plugins: plugins)

/// 网络服务单例（添加加载动画使用）
class HttpServer {
    static let share = HttpServer()
    private let rxCache = RxCache()

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

    func request<T>(api: TargetType & MoyaAddable, type: DataType, callback: Observer<T>) where T: Mappable {
        let observable = request(api: api)
        api.policy
    }

    func request(api: TargetType) -> Observable<Response> {
        return provider.rx.request(MultiTarget(api)).asObservable()
    }

    enum DataType {
        case object
        case list
        case string
    }
}

class Server {
    static private let server = HttpServer.share

    static func getUserInfo(id: Int, callback: Observer<User>) {
        server.request(api: UserApi.info(id: id), type: .object, callback: callback)
    }
}

class Observer<Element> {
    public typealias EventHandler = (Result<Element, Error>) -> Void

    let observer: AnyObserver<Element>

    init(_ handler: @escaping EventHandler) {
        observer = AnyObserver<Element> { (event) in
            switch event {
            case .next(let item):
                handler(.success(item))
            case .error(let error):
                handler(.failure(error))
            case .completed: break
            }
        }
    }
}

class Test {
    func test() {
        Server.getUserInfo(id: 0, callback: Observer<User> { result in
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                print(error)
            }
        })
    }
}

// MARK: - 数据模型
struct ResultModel<M: Mappable>: Mappable {
    var code: Int = 0
    var result: M?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        code    <- map["code"]
        result  <- map["result"]
    }
}

struct User: Mappable {
    var id: String = ""
    var numId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id    <- map["id"]
        numId  <- map["numId"]
    }
}

extension Response {
}

struct HttpResult {
    var statusCode: Int
    var data: String
}
