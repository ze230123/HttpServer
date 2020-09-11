//
//  UserDefaults.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/2.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

var defaults = Defaults

extension DefaultsKeys {
    var likeCollegeList: DefaultsKey<[Int]> { .init("LikeCollegeList", defaultValue: []) }
}

// MARK: - 接口缓存模式
extension DefaultsKeys {
    var cacheCollegeMode: DefaultsKey<Int> { .init("CacheCollegeMode", defaultValue: 1) }
    var cacheMajorMode: DefaultsKey<Int> { .init("CacheMajorMode", defaultValue: 1) }
    var cachePclMode: DefaultsKey<Int> { .init("CachePclMode", defaultValue: 1) }
    var cacheOtherMode: DefaultsKey<Int> { .init("CacheOtherMode", defaultValue: 1) }
}
