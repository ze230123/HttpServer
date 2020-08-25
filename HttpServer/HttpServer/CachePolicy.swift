//
//  CachePolicy.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya


/// 缓存配置
///
/// 设置接口path、接口参数、缓存所属模块、过期时间
struct CacheConfig {
    enum Module {
        case college
        case major
        case pcl
        case other

        var value: String {
            switch self {
            case .college:
                return "1"
            case .major:
                return "2"
            case .pcl:
                return "3"
            case .other:
                return "4"
            }
        }
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

    var api: String {
        return path
    }

    var parameter: String {
        let keyValue = parameters.map { "\($0.key)\($0.value)"}.sorted().joined(separator: "")
        return keyValue + module.value
    }

    /// 缓存key
    var key: String {
        return api + parameter
    }
}

/// 缓存策略
enum CachePolicy {
    /// 不用缓存
    case none(CacheConfig)
    /// 先用缓存，不管有没有都请求网络, 如果网络返回的数据与缓存不一样就再返回网络数据
    case cacheAndRequest(CacheConfig)
    /// 先用缓存，没有在请求网络
    case firstCache(CacheConfig)
    /// 先请求网络，失败后再返回缓存
    case firstRequest(CacheConfig)

    var strategy: BaseStrategy {
        switch self {
        case let .none(config):
            return NoCacheStrategy(config: config)
        case let .cacheAndRequest(config):
            return CacheAndRemoteDistinctStrategy(config: config)
        case let .firstCache(config):
            return FirstCacheStrategy(config: config)
        case let .firstRequest(config):
            return FirstRequestStrategy(config: config)
        }
    }
}
