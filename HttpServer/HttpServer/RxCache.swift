//
//  RxCache.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import Security
import RxSwift
import Alamofire

class RxCache {
}

/// 缓存策略基类
class BaseStrategy {
    fileprivate let config: CacheConfig

    init(config: CacheConfig) {
        self.config = config
    }

//    func loadCache(_ rxCache: RxCache, apiName: String) -> Observable<>
    /// 执行操作
    /// - Parameters:
    ///   - rxCache: 缓存工具
    ///   - apiName: 接口名+参数
    ///   - time: 缓存时间
    ///   - observable: 正常的请求
    func execute(_ rxCache: RxCache, observable: Observable<ResponseCacher>) {
    }
}

class NoCacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, observable: Observable<ResponseCacher>) {
    }
}

class CacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, observable: Observable<ResponseCacher>) {
        
    }
}

class FirstCacheStrategy: BaseStrategy {
}

class FirstRequestStrategy: BaseStrategy {
}
