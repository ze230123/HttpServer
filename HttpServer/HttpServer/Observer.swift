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

class ListMapHandler<Element> where Element: Mappable {
    func map(_ JSONString: String) throws -> [Element] {
        guard let item = Mapper<Element>().mapArray(JSONfile: JSONString) else {
            throw HttpError.objectMapping(jsonString: JSONString, object: "\(Element.self)")
        }
        return item
    }
}

///// Rx观察者基类：使用它的子类
//class Observer<Element>: ObserverType {
//    typealias EventHandler = (Result<Element, HttpError>) -> Void
//    typealias MapObjectHandler = (String) throws -> Element
//
//    private let handler: EventHandler
//    let disposeBag: DisposeBag
//
//    deinit {
//        print("\(self)_deinit")
//    }
//
//    init(disposeBag: DisposeBag, handler: @escaping EventHandler) {
//        self.disposeBag = disposeBag
//        self.handler = handler
//    }
//
//    func on(_ event: Event<Element>) {
//        switch event {
//        case .next(let item):
//            handler(.success(item))
//        case .error(let error):
//            handler(.failure(catchError(error)))
//        case .completed: break
//        }
//    }
//
//    func mapObject() -> MapObjectHandler {
//        fatalError()
//    }
//
//    private func catchError(_ error: Error) -> HttpError {
//        return ApiException.handleException(error)
//    }
//}
//
///// 数据模型观察者
//class ObjectObserver<Element>: Observer<Element> where Element: Mappable {
//    override func mapObject() -> Observer<Element>.MapObjectHandler {
//        return { (value) -> Element in
//            return try ObjectMapHandler<Element>().map(value)
//        }
//    }
//}
//
//class StringObserver: Observer<String> {
//    override func mapObject() -> Observer<String>.MapObjectHandler {
//        return { value -> String in
//            return value
//        }
//    }
//}

//class VoidObserver: Observer<Void> {
//}


class Observer<Element>: ObserverType {
    typealias EventHandler = (Result<Element, HttpError>) -> Void

    let disposeBag: DisposeBag
    let observer: EventHandler

    init<Observer>(disposeBag: DisposeBag, observer: Observer) where Element == Observer.Element, Observer: HttpResultHandler {
        self.disposeBag = disposeBag
        self.observer = { [weak observer] result in
            observer?.resultHandler(result)
        }
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next(let item):
            observer(.success(item))
        case .error(let error):
            observer(.failure(ApiException.handleException(error)))
        case .completed: break
        }
    }
}










class NewObjectObserver<Element>: ObserverType where Element: Mappable {
    typealias EventHandler = (Result<Element, HttpError>) -> Void

    let map = ObjectMap<Element>()

    let disposeBag: DisposeBag
    let observer: EventHandler

    init<Observer>(disposeBag: DisposeBag, observer: Observer) where Element == Observer.Element, Observer: HttpResultHandler {
        self.disposeBag = disposeBag
        self.observer = { [weak observer] result in
            observer?.resultHandler(result)
        }
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next(let item):
            observer(.success(item))
        case .error(let error):
            observer(.failure(ApiException.handleException(error)))
        case .completed: break
        }
    }
}

/// 列表数据观察者
///
/// `ListElement`没有限定类型，如果有自定义类型和继承此类，自行实现mapObject()
/// `Mappable`类型的数据模型请使用`ObjectListObserver`
class ListObserver<ListElement>: ObserverType {
    typealias Element = [ListElement]

    typealias EventHandler = (Result<Element, HttpError>) -> Void

    let disposeBag: DisposeBag
    let observer: EventHandler

    init<Observer>(disposeBag: DisposeBag, observer: Observer) where Element == Observer.Element, Observer: HttpResultHandler {
        self.disposeBag = disposeBag
        self.observer = { [weak observer] result in
            observer?.resultHandler(result)
        }
    }

    func on(_ event: Event<[ListElement]>) {
        switch event {
        case .next(let item):
            observer(.success(item))
        case .error(let error):
            observer(.failure(ApiException.handleException(error)))
        case .completed: break
        }
    }
}

class ObjectListObserver<ListElement>: ListObserver<ListElement> where ListElement: Mappable {
    let map = ListMap<ListElement>()
}
