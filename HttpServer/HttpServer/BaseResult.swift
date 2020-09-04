//
//  BaseResult.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

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
