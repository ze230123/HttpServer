//
//  ConfigApi.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

enum ConfigApi {
    case cache
}

extension ConfigApi: TargetType, MoyaAddable {
    var policy: CachePolicy {
        switch self {
        case .cache:
            return .none(CacheConfig(path: path, parameters: task.parameters))
        }
    }

    var task: Task {
        switch self {
        case .cache:
//            AndroidCacheConfig
            return .requestParameters(parameters: ["identification": "Android缓存配置"], encoding: URLEncoding.queryString)
        }
    }

    var path: String {
        switch self {
        case .cache:
            return "/SiteSettings/Get"
        }
    }

    var method: Method {
        return .post
    }

    var baseURL: URL {
        return URL(string: "http://106.75.118.194:5101")!
    }
}
