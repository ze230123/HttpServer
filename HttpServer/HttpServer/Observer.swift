//
//  Observer.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

/// 数据模型转换处理
class ObjectMapHandler<Element> where Element: Mappable {
    func map(_ JSONString: String) throws -> Element {
        guard let item = Mapper<Element>().map(JSONString: JSONString) else {
            throw HttpError.objectMapping(jsonString: JSONString, object: "\(Element.self)")
        }
        return item
    }
}

/// Rx观察者基类：使用它的子类
class Observer<Element>: ObserverType {
    typealias EventHandler = (Result<Element, HttpError>) -> Void
    typealias MapObjectHandler = (String) throws -> Element

    private let handler: EventHandler

    deinit {
        print("\(self)_deinit")
    }

    init(_ handler: @escaping EventHandler) {
        self.handler = handler
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next(let item):
            handler(.success(item))
        case .error(let error):
            handler(.failure(self.catchError(error)))
        case .completed: break
        }
    }

    func mapObject() -> MapObjectHandler {
        fatalError()
    }

    private func catchError(_ error: Error) -> HttpError {
        print(error)
        return HttpError.noCache
    }
}

/// 数据模型观察者
class ObjectObserver<Element>: Observer<Element> where Element: Mappable {
    override func mapObject() -> Observer<Element>.MapObjectHandler {
        return { (value) -> Element in
            return try ObjectMapHandler<Element>().map(value)
        }
    }
}

/// login观察者
///
/// 多个接口返回模型的聚合模型
class LoginObserver: Observer<Login> {
    func mapUser() -> (String) throws -> User {
        return { (value) -> User in
            return try ObjectMapHandler<User>().map(value)
        }
    }

    func mapScore() -> (String) throws -> Score {
        return { (value) -> Score in
            return try ObjectMapHandler<Score>().map(value)
        }
    }

    func mapLogin() -> (User, Score) -> Login {
        return { (user, score) in
            return Login(user: user, score: score)
        }
    }
}
