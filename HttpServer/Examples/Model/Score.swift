//
//  Score.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

/// 文理科枚举
enum Course: Int {
    /// 未选
    case none = -1
    /// 理科
    case science
    /// 文科
    case arts
}

struct Score: Mappable {
    var numId: Int = 0
    var scoreType: Int = 0
    var total: Int = 0
    var course: Course = .none

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        numId       <- map["numId"]
        scoreType   <- map["scoreType"]
        total       <- map["total"]
        course      <- (map["course"], EnumTransform<Course>())
    }
}
