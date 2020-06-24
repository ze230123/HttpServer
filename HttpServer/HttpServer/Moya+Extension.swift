//
//  Moya+Extension.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

struct CacheConfig {
    enum Module {
        case college
        case major
        case pcl
        case other
    }

    var path: String
    var parameters: [String: Any]
    var module: Module
    var expiry: Expiry
}

/// 缓存策略
enum CachePolicy {
    /// 不用缓存
    case none
    /// 用缓存，没有在请求网络
    case cache(CacheConfig)
    /// 先用缓存，在请求网络，得到网络数据后覆盖缓存
    case firstCache(CacheConfig)
    /// 先请求网络，失败后再返回缓存
    case firstRequest(CacheConfig)
}

protocol MoyaAddable {
    var policy: CachePolicy { get }
}



extension Task {
    var parameters: [String: Any] {
        switch self {
        case let .requestParameters(parameters, _):
            return parameters
        default:
            return [:]
        }
    }
}
