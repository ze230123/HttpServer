//
//  CacheCore.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

/// 缓存类
final class CacheCore {
    static let shared = CacheCore()

    private let store = DiskStorage<String>(
        config: DiskConfig(
            name: "URLCache",
            maxSize: 1024 * 10,
            expiry: .never),
        transformer: TransformerFactory.forString()
    )

    init() {
        print(store.path)
    }

    func setCache(_ cache: String, key: String, expiry: Expiry? = nil) {
        store.setObject(cache, forKey: key.md5, expiry: expiry)
    }

    func cache(for key: String) -> String? {
        return store.object(forKey: key.md5)
    }

    var totalSize: UInt64 {
        return store.totalSize()
    }

    func removeAll() {
        store.removeAll()
    }
}
