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

    /// 正常请求 获取用户信息
    /// - Parameters:
    ///   - id: 用户ID
    ///   - callback: 回调对象
    static func getUserInfo(id: Int, observer: NewObjectObserver<User>) {
        server
            .request(api: UserApi.info(id: id), map: observer.map)
//            .request(api: UserApi.info(id: id), mapHandler: callback.mapObject())
            .subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 正常请求，获取成绩
    /// - Parameters:
    ///   - numId: 用户ID
    ///   - proId: 省份ID
    ///   - callback: 回调对象
    static func getScore(numId: Int, proId: Int, observer: NewObjectObserver<Score>) {
        server
            .request(api: ScoreApi.getByUser(numId: numId, proId: proId), map: observer.map)
//            .request(api: ScoreApi.getByUser(numId: numId, proId: proId), mapHandler: callback.mapObject())
            .subscribe(observer)
            .disposed(by: observer.disposeBag)
    }

    /// 依赖请求，及后一个请求需要前一个请求的结果
    /// - Parameters:
    ///   - id: 用户ID
    ///   - callback: 回调对象
    static func login(id: Int, callback: LoginObserver) {
//        server
//            .request(api: UserApi.info(id: id), mapHandler: callback.mapUser())
//            .flatMap { (user) -> Observable<Login> in
//                return server
//                    .request(api: ScoreApi.getByUser(numId: user.numId, proId: user.provinceId), mapHandler: callback.mapScore())
//                    .map { (score) -> Login in
//                        return Login(user: user, score: score)
//                    }
//            }.subscribe(callback).disposed(by: callback.disposeBag)
    }

    /// 同时请求
    /// - Parameters:
    ///   - id: 用户ID
    ///   - proId: 省份ID
    ///   - callback: 回调对象
    static func zipLogin(id: Int, proId: Int, callback: LoginObserver) {
        
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
            .subscribe(observer)
            .disposed(by: observer.disposeBag)
//        server
////            .request(api: CollegeApi.all(parameter), mapHandler: observer.mapObject())
//            .newRequest(api: CollegeApi.all(parameter), oberver: observer)
//            .subscribe(observer)
//            .disposed(by: observer.disposeBag)
    }

    /// 关注院校
    /// - Parameters:
    ///   - id: 院校ID
    ///   - isLike: true：已关注，false: 未关注
    ///   - observer: 回调对象
    static func likeCollege(id: Int, name: String, isLike: Bool, observer: StringObserver) {
//        var api: CollegeApi
//
//        if isLike {
//            api = .delete(id: id, name: name)
//        } else {
//            api = .insert(id: id, name: name)
//        }
//
//        server
//            .request(api: api, mapHandler: observer.mapObject())
//            .subscribe(observer)
//            .disposed(by: observer.disposeBag)
    }
}

import ObjectMapper

struct ObjectResult<Element>: Mappable where Element: Mappable {
    var message: String = ""
    var result: Element?
    var code: String = ""
    var isSuccess: Bool = false

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        message     <- map["message"]
        result      <- map["result"]
        code        <- map["code"]
        isSuccess   <- map["isSuccess"]
    }
}

struct ListResult<Element>: Mappable where Element: Mappable {
    var message: String = ""
    var result: [Element] = []
    var code: String = ""
    var isSuccess: Bool = false

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        message     <- map["message"]
        result      <- map["result"]
        code        <- map["code"]
        isSuccess   <- map["isSuccess"]
    }
}

protocol MapHandler {
    associatedtype Element
    func mapObject() -> (String) throws -> Element
    func mapObject(_ value: String) throws -> Element
    func mapString(_ value: Element) -> String
    func mapCache(_ value: Element) -> String
}

struct ObjectMap<Element>: MapHandler where Element: Mappable {
    func mapObject() -> (String) throws -> Element {
        return { value in
            guard let item = Mapper<ObjectResult<Element>>().map(JSONString: value) else {
                throw HttpError.objectMapping(jsonString: value, object: "\(Element.self)")
            }
            guard item.isSuccess else {
                throw HttpError.message(item.message)
            }
            guard let result = item.result else {
                throw HttpError.dataMapping
            }
            return result
        }
    }

    func mapObject(_ value: String) throws -> Element {
        guard let item = Mapper<Element>().map(JSONString: value) else {
            throw HttpError.objectMapping(jsonString: value, object: "\(Element.self)")
        }
        return item
    }

    func mapString(_ value: Element) -> String {
        return value.toString()
    }

    func mapCache(_ value: Element) -> String {
        return value.toJSONString(prettyPrint: true) ?? ""
    }
}

struct ListMap<ListElement>: MapHandler where ListElement: Mappable {
    typealias Element = [ListElement]

    func mapObject() -> (String) throws -> Element {
        return { value in
            guard let item = Mapper<ListResult<ListElement>>().map(JSONString: value) else {
                throw HttpError.objectMapping(jsonString: value, object: "\(Element.self)")
            }
            guard item.isSuccess else {
                throw HttpError.message(item.message)
            }
            return item.result
        }
    }

    func mapObject(_ value: String) throws -> Element {
        guard let item = Mapper<ListElement>().mapArray(JSONfile: value) else {
            throw HttpError.objectMapping(jsonString: value, object: "\(Element.self)")
        }
        return item
    }

    func mapString(_ value: Element) -> String {
        return value.toString()
    }

    func mapCache(_ value: Element) -> String {
        return value.toJSONString(prettyPrint: true) ?? ""
    }
}

extension Mappable {
    /// 将模型转为排序后的字符串
    /// - Returns: 字符串
    func toString() -> String {
        if #available(iOS 11.0, *) {
            guard let data = try? JSONSerialization.data(withJSONObject: toJSON(), options: [.sortedKeys]),
                let value = String(data: data, encoding: .utf8) else {
                    return ""
            }
            return value
        } else {
            // iOS 11 以下的系统手动转换
            func formate(_ parameters: [String: Any]) -> String {
                let arr = parameters.map { (item) -> String in
                    if let dict = item.value as? [String: Any] {
                        return formate(dict)
                    } else {
                        return "\(item.key)=\(item.value)"
                    }
                }
                let value = arr.sorted().joined(separator: ",")
                return value
            }
            return formate(toJSON())
        }
    }
}

public extension Array where Element: Mappable {
    /// Returns the JSON Array
    func toJSON() -> [[String: Any]] {
        return Mapper().toJSONArray(self)
    }

    /// Returns the JSON String for the object
    func toJSONString(prettyPrint: Bool = false) -> String? {
        return Mapper().toJSONString(self, prettyPrint: prettyPrint)
    }

    /// 将模型转为排序后的字符串
    /// - Returns: 字符串
    func toString() -> String {
        if #available(iOS 11.0, *) {
            guard let data = try? JSONSerialization.data(withJSONObject: toJSON(), options: [.sortedKeys]),
                let value = String(data: data, encoding: .utf8) else {
                    return ""
            }
            return value
        } else {
            // iOS 11 以下的系统手动转换
            func formate(_ parameters: [String: Any]) -> String {
                let arr = parameters.map { (item) -> String in
                    if let dict = item.value as? [String: Any] {
                        return formate(dict)
                    } else {
                        return "\(item.key)=\(item.value)"
                    }
                }
                let value = arr.sorted().joined(separator: ",")
                return value
            }
            let value = toJSON().map { formate($0) }.joined(separator: ",")
            return value
        }
    }
}
