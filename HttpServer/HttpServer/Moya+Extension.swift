//
//  Moya+Extension.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

typealias Parameters = [String: Any]
typealias Method = Moya.Method

struct CacheConfig {
    enum Module {
        case college
        case major
        case pcl
        case other
    }

    var path: String
    var parameters: Parameters
    var module: Module
    var expiry: Expiry

    init(path: String, parameters: Parameters) {
        self.path = path
        self.parameters = parameters
        self.module = .other
        self.expiry = .never
    }

    init(path: String, parameters: Parameters, module: Module, expiry: Expiry) {
        self.path = path
        self.parameters = parameters
        self.module = module
        self.expiry = expiry
    }
}

/// 缓存策略
enum CachePolicy {
    /// 不用缓存
    case none(CacheConfig)
    /// 用缓存，没有在请求网络
    case cache(CacheConfig)
    /// 先用缓存，在请求网络，得到网络数据后覆盖缓存
    case firstCache(CacheConfig)
    /// 先请求网络，失败后再返回缓存
    case firstRequest(CacheConfig)

    var strategy: BaseStrategy {
        switch self {
        case let .none(config):
            return NoCacheStrategy(config: config)
        case let .cache(config):
            return CacheStrategy(config: config)
        case let .firstCache(config):
            return FirstCacheStrategy(config: config)
        case let .firstRequest(config):
            return FirstRequestStrategy(config: config)
        }
    }
}

protocol MoyaAddable {
    var policy: CachePolicy { get }
}

extension Task {
    var parameters: Parameters {
        switch self {
        case let .requestParameters(parameters, _):
            return parameters
        default:
            return [:]
        }
    }
}
