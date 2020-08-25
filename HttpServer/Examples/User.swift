//
//  User.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

/// 性别
enum Gender: Int {
    case none = -1
    /// 女
    case female = 0
    /// 男
    case male = 1
}

struct User: Mappable {
    var id: String = ""
    var numId: Int = 0
    var gender: Gender = .male
    var provinceId: Int = 0

    init(id: String, numId: Int, gender: Gender) {
        self.id = id
        self.numId = numId
        self.gender = gender
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id    <- map["id"]
        numId  <- map["numId"]
        gender  <- (map["gender"], EnumTransform<Gender>())
        provinceId  <- map["provinceId"]
    }
}


struct Login {
    var user: User
    var score: Score
}
