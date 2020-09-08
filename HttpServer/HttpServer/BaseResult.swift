//
//  BaseResult.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

extension Map {
    func toJSONString() -> String? {
        guard let dict = currentValue, JSONSerialization.isValidJSONObject(dict) else {
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

struct ObjectResult<Element>: Mappable where Element: Mappable {
    var message: String = ""
    var result: Element?
    var code: String = ""
    var isSuccess: Bool = false

    var resultValue: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        message     <- map["message"]
        result      <- map["result"]
        code        <- map["code"]
        isSuccess   <- map["isSuccess"]

        resultValue = map["result"].toJSONString()
    }
}

struct ListResult<Element>: Mappable where Element: Mappable {
    var message: String = ""
    var result: [Element] = []
    var code: String = ""
    var isSuccess: Bool = false

    var resultValue: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        message     <- map["message"]
        result      <- map["result"]
        code        <- map["code"]
        isSuccess   <- map["isSuccess"]

        resultValue = map["result"].toJSONString()
    }
}

struct StringResult: Mappable {
    var message: String = ""
    var result: String = ""
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

/// 缓存用到的模型
struct CacheResult<Element> {
    /// 服务器`Result`jsonString
    let jsonString: String?
    /// `Result`解析后的模型
    let result: Element

    init(jsonString: String?, result: Element) {
        self.jsonString = jsonString
        self.result = result
    }
}
