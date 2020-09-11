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

/// RxSwift 观察者处理协议
///
/// 将闭包转为方法
protocol ObserverHandler where Self: BaseViewController {
    associatedtype Element
    func resultHandler(_ result: Result<Element, APIError>)
}

/// 任意对象观察者
class Observer<Element>: ObserverType {
    typealias EventHandler = (Result<Element, APIError>) -> Void

    let disposeBag: DisposeBag
    let observer: EventHandler

    deinit {
        print("\(self)_deinit")
    }

    init<Observer>(disposeBag: DisposeBag, observer: Observer) where Element == Observer.Element, Observer: ObserverHandler {
        self.disposeBag = disposeBag
        self.observer = { [weak observer] result in
            observer?.resultHandler(result)
        }
    }

    init(disposeBag: DisposeBag, observer: @escaping EventHandler) {
        self.disposeBag = disposeBag
        self.observer = observer
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

/// 遵守`Mappable`协议观察者
class ObjectObserver<Element>: Observer<Element> where Element: Mappable {
    let map = ObjectMap<Element>()
}

/// 任意对象列表观察者
///
/// `ListElement`没有限定类型，如果有自定义类型和继承此类，自行实现mapObject()
/// `Mappable`类型的数据模型请使用`ObjectListObserver`
class ListObserver<ListElement>: ObserverType {
    typealias Element = [ListElement]

    typealias EventHandler = (Result<Element, APIError>) -> Void

    let disposeBag: DisposeBag
    let observer: EventHandler

    deinit {
        print("\(self)_deinit")
    }

    init<Observer>(disposeBag: DisposeBag, observer: Observer) where Element == Observer.Element, Observer: ObserverHandler {
        self.disposeBag = disposeBag
        self.observer = { [weak observer] result in
            observer?.resultHandler(result)
        }
    }

    init(disposeBag: DisposeBag, observer: @escaping EventHandler) {
        self.disposeBag = disposeBag
        self.observer = observer
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

/// 对象列表观察者
///
/// `ListElement`遵守`Mappable`协议
class ObjectListObserver<ListElement>: ListObserver<ListElement> where ListElement: Mappable {
    let map = ListMap<ListElement>()
}

/// 返回String或`Result`没有返回的观察者
class VoidObserver: Observer<String> {
    let map = StringMap()
}
