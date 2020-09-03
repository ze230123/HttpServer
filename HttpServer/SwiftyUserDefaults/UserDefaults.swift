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

