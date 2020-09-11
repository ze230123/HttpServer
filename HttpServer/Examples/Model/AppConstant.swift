//
//  AppConstant.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

struct AppConstant {
    struct CacheMode {
        static var college: Int = 1
        static var major: Int = 1
        static var pcl: Int = 1
        static var other: Int = 1

        static func update(_ config: Config) {
            college = config.college
            major = config.major
            pcl = config.pcl
            other = config.other

            defaults.cacheCollegeMode = college
            defaults.cacheMajorMode = major
            defaults.cachePclMode = pcl
            defaults.cacheOtherMode = other

            printMessage("model")
        }

        static func updateFromDefaults() {
            college = defaults.cacheCollegeMode
            major = defaults.cacheMajorMode
            pcl = defaults.cachePclMode
            other = defaults.cacheOtherMode
            printMessage("defaults")
        }

        static func printMessage(_ tag: String) {
            print("----------------- CacheMode from \(tag) -----------------")
            print("college -", college, "major -", major, "pcl -", pcl, "other -", other)
            print("----------------- CacheMode from \(tag) -----------------")
        }
    }
}
