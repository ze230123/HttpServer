//
//  MapHandler.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

/// 数据模型转换处理
fileprivate struct ObjectMapHandler<Element> where Element: Mappable {
    func mapRoot(_ JSONString: String) throws -> (String?, Element) {
        guard let item = Mapper<ObjectResult<Element>>().map(JSONString: JSONString) else {
            throw APIError(mode: .dataMapping)
        }
        guard item.isSuccess else {
            throw APIError(mode: .server(item.message))
        }
        guard let result = item.result else {
            throw APIError(mode: .modelMapping)
        }
        return (item.resultValue, result)
    }

    func mapResult(_ JSONString: String) throws -> Element {
        guard let item = Mapper<Element>().map(JSONString: JSONString) else {
            throw APIError(mode: .dataMapping)
        }
        return item
    }
}
/// 数据模型转换处理
fileprivate struct ListMapHandler<Element> where Element: Mappable {
    func mapRoot(_ JSONString: String) throws -> (String?, [Element]) {
        guard let item = Mapper<ListResult<Element>>().map(JSONString: JSONString) else {
            throw APIError(mode: .dataMapping)
        }
        guard item.isSuccess else {
            throw APIError(mode: .server(item.message))
        }
        return (item.resultValue, item.result)
    }

    func mapList(_ JSONString: String) throws -> [Element] {
        guard let item = Mapper<Element>().mapArray(JSONString: JSONString) else {
            throw APIError(mode: .dataMapping)
        }
        return item
    }
}
/// 数据模型转换处理
fileprivate struct StringMapHandler {
    func map(_ JSONString: String) throws -> String {
        guard let item = Mapper<StringResult>().map(JSONString: JSONString) else {
            throw APIError(mode: .dataMapping)
        }
        guard item.isSuccess else {
            throw APIError(mode: .server(item.message))
        }
        return item.result
    }
}

/// 数据转换处理协议
protocol MapHandler {
    /// 数据类型
    associatedtype Element
    /// 服务器json转模型
    func mapObject() -> (String) throws -> CacheResult<Element>
    /// 本地缓存json转模型
    func mapObject(_ value: String) throws -> CacheResult<Element>
    /// 模型转排序后的字符串
    ///
    /// 用于本地数据和网络数据比对
    func mapString(_ value: CacheResult<Element>) -> String?
}

/// 对象转换工具
///
/// `result`为字典时使用此方法
struct ObjectMap<Element>: MapHandler where Element: Mappable {
    func mapObject() -> (String) throws -> CacheResult<Element> {
        return { value in
            let (jsonString, result) = try ObjectMapHandler<Element>().mapRoot(value)
            return CacheResult<Element>(jsonString: jsonString, result: result)
        }
    }

    func mapObject(_ value: String) throws -> CacheResult<Element> {
        let result = try ObjectMapHandler<Element>().mapResult(value)
        return CacheResult<Element>(jsonString: value, result: result)
    }

    func mapString(_ value: CacheResult<Element>) -> String? {
        return value.jsonString
    }
}

/// 数组转换工具
///
/// `result`为数组时使用此方法
struct ListMap<ListElement>: MapHandler where ListElement: Mappable {
    typealias Element = [ListElement]

    func mapObject() -> (String) throws -> CacheResult<Element> {
        return { value in
            let (jsonString, result) = try ListMapHandler<ListElement>().mapRoot(value)
            return CacheResult<Element>(jsonString: jsonString, result: result)
        }
    }

    func mapObject(_ value: String) throws -> CacheResult<Element> {
        let result = try ListMapHandler<ListElement>().mapList(value)
        return CacheResult<Element>(jsonString: value, result: result)
    }

    func mapString(_ value: CacheResult<Element>) -> String? {
        return value.jsonString
    }
}

/// String转换工具
///
/// `result`为String或没有`result`字段时使用此方法
struct StringMap: MapHandler {
    typealias Element = String

    func mapObject() -> (String) throws -> CacheResult<String> {
        return { value in
            let result = try StringMapHandler().map(value)
            return CacheResult(jsonString: result, result: result)
        }
    }

    func mapObject(_ value: String) throws -> CacheResult<String> {
        return CacheResult(jsonString: value, result: value)
    }

    func mapString(_ value: CacheResult<Element>) -> String? {
        return value.jsonString
    }
}
