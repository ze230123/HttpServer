//
//  MapHandler.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

/// 数据转换处理协议
protocol MapHandler {
    /// 数据类型
    associatedtype Element
    /// 服务器json转模型
    func mapObject() -> (String) throws -> Element
    /// 本地缓存json转模型
    func mapObject(_ value: String) throws -> Element
    /// 模型转排序后的字符串
    ///
    /// 用于本地数据和网络数据比对
    func mapString(_ value: Element) -> String
    /// 数据模型转本地缓存json，本地缓存只缓存`result`字段数据
    func mapCache(_ value: Element) -> String
}

/// 对象转换工具
///
/// `result`为字典时使用此方法
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
        return value.toSortString()
    }

    func mapCache(_ value: Element) -> String {
        return value.toJSONString(prettyPrint: true) ?? ""
    }
}

/// 数组转换工具
///
/// `result`为数组时使用此方法
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
        return value.toSortString()
    }

    func mapCache(_ value: Element) -> String {
        return value.toJSONString(prettyPrint: true) ?? ""
    }
}

/// String转换工具
///
/// `result`为String或没有`result`字段时使用此方法
struct StringMap: MapHandler {
    typealias Element = String

    func mapObject() -> (String) throws -> String {
        return { value in
            guard let item = Mapper<StringResult>().map(JSONString: value) else {
                throw HttpError.objectMapping(jsonString: value, object: "\(Element.self)")
            }
            guard item.isSuccess else {
                throw HttpError.message(item.message)
            }
            return item.result
        }
    }

    func mapObject(_ value: String) throws -> String {
        return value
    }

    func mapString(_ value: String) -> String {
        return value
    }

    func mapCache(_ value: String) -> String {
        return value
    }
}

fileprivate extension Mappable {
    /// 将模型转为排序后的字符串
    /// - Returns: 字符串
    func toSortString() -> String {
        return toJSON().toSortString()
    }
}

fileprivate extension Array where Element: Mappable {
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
    func toSortString() -> String {
        if #available(iOS 11.0, *) {
            guard let data = try? JSONSerialization.data(withJSONObject: toJSON(), options: [.sortedKeys]),
                let value = String(data: data, encoding: .utf8) else {
                    return ""
            }
            return value
        } else {
            let value = toJSON().map { $0.toSortString() }.joined(separator: ",")
            return value
        }
    }
}
