//
//  CollegeApi.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

struct AllCollegeParameter {
    var pageIndex: Int = 1
    var pageSize: Int = 20

    var parameters: [String: Any] {
        return [
            "provinceIds": [],
            "levels": [
                "firstClass": false,
                "is211": false,
                "is985": false,
                "isKey": false,
                "isProvincial": false
            ],
            "classify": [],
            "natures": [],
            "arts": [],
            "isArt": false,
            "isBen": -1,
            "type": -1,
            "isSingleRecruit": false,
            "wordSegment": false,
            "keywords": "",
            "pageIndex": pageIndex,
            "pageSize": pageSize
        ]
    }
}

enum CollegeApi {
    case all(AllCollegeParameter)
}

extension CollegeApi: TargetType, MoyaAddable {
    var policy: CachePolicy {
        switch self {
        case .all:
            return .firstCache(CacheConfig(path: path, parameters: task.parameters, module: .college, expiry: .time(.day(1))))
        }
    }

    var task: Task {
        switch self {
        case let .all(parameter):
            return .requestParameters(parameters: parameter.parameters, encoding: JSONEncoding.default)
        }
    }

    var path: String {
        switch self {
        case .all:
            return "Colleges/Query"
        }
    }

    var method: Method {
        return .post
    }

    var baseURL: URL {
        return URL(string: "http://106.75.118.194:5001")!
    }
}

