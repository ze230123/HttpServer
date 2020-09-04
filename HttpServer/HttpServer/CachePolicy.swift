//
//  CachePolicy.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya
/// 将参数字典转换为字符串
extension Dictionary where Key == String, Value == Any {
    func toSortString() -> String {
        // iOS 11 以上的系统使用JSONSerialization转换为json字符串
        if #available(iOS 11.0, *) {
            guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.sortedKeys]),
                let value = String(data: data, encoding: .utf8) else {
                    return ""
            }
            return value
        } else {
            // iOS 11 以下的系统手动转换
            func formate(_ parameters: [String: Any]) -> String {
                let arr = parameters.map { (item) -> String in
                    if let dict = item.value as? [String: Any] {
                        return formate(dict)
                    } else {
                        return "\(item.key)=\(item.value)"
                    }
                }
                let value = arr.sorted().joined(separator: ",")
                return value
            }
            return formate(self)
        }
    }
}

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

    let api: String
    let parameters: String
    let module: Module
    let expiry: Expiry

    init(path: String, parameters: Parameters, module: Module = .other, expiry: Expiry = .never) {
        self.api = path
        self.parameters = parameters.toSortString()
        self.module = module
        self.expiry = expiry
    }

    /// 缓存key
    var key: String {
        return api + parameters + module.value
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
