//
//  AppConfig.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

struct AppConfig: Mappable {
    var settingsJson: String = ""
    var name: String = ""
    var id: String = ""
    var numId: Int = 0
    var description: String = ""
    var identification: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        settingsJson   <- map["settingsJson"]
        name   <- map["name"]
        id   <- map["id"]
        numId   <- map["numId"]
        description   <- map["description"]
        identification   <- map["identification"]
    }
}
