//
//  Banners.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

//struct Banners: Mappable {
//    var androidUrl: String = ""
//    var numId: Int = 0
//    var iosUrl: String = ""
//    var pictureUrl: String = ""
//    var title: String = ""
//    var videoId: Int = 0
//    var introduction: String = ""
//    var url: String = ""
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        androidUrl   <- map["androidUrl"]
//        numId   <- map["numId"]
//        iosUrl   <- map["iosUrl"]
//        pictureUrl   <- map["pictureUrl"]
//        title   <- map["title"]
//        videoId   <- map["videoId"]
//        introduction   <- map["introduction"]
//        url   <- map["url"]
//
//        if iosUrl.contains("onlineBuy") || iosUrl.contains("servicesBuy") {
//            iosUrl = "youzy://eagersoft.com:200/pay/product"
//        }
//    }
//}

struct Banners: Mappable {
    var pcUrl: String = ""
    var androidUrl: String = ""
    var iosUrl: String = ""
    var androidVideoId: Int = 0
    var status: Int = 0
    var mobilePictureUrl: String = ""
    var bannerType: Int = 0
    var numId: Int = 0
    var pcPictureUrl: String = ""
    var mobileUrl: String = ""
    var title: String = ""
    var iosVideoId: Int = 0
    var provinceNumId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        pcUrl   <- map["pcUrl"]
        androidUrl   <- map["androidUrl"]
        iosUrl   <- map["iosUrl"]
        androidVideoId   <- map["androidVideoId"]
        status   <- map["status"]
        mobilePictureUrl   <- map["mobilePictureUrl"]
        bannerType   <- map["bannerType"]
        numId   <- map["numId"]
        pcPictureUrl   <- map["pcPictureUrl"]
        mobileUrl   <- map["mobileUrl"]
        title   <- map["title"]
        iosVideoId   <- map["iosVideoId"]
        provinceNumId   <- map["provinceNumId"]
    }
}
