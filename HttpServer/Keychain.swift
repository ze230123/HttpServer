//
//  Keychain.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

struct Order: Codable {
    var orderNo: String
    var iapOrderNo: String
    var provinceId: Int
    var userId: Int

    var data: Data? {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(self)
        return jsonData
    }

    static func order(_ data: Data) -> Order? {
        let jsonDecoder = JSONDecoder()
        let model: Order? = try? jsonDecoder.decode(Order.self, from: data)
        return model
    }

    var isEmpty: Bool {
        return orderNo.isEmpty || iapOrderNo.isEmpty
    }
}

/// 支付订单存储
class OrderStored {
    func set(_ order: Order, for key: String) -> Bool {
        guard !key.isEmpty, let data = order.data else { return false }

        let matchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        var status = SecItemCopyMatching(matchQuery as CFDictionary, nil)

        if status == errSecSuccess {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        } else if status == errSecItemNotFound {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            status = SecItemAdd(query as CFDictionary, nil)
        }

        return status == errSecSuccess
    }

    func get(_ key: String) -> Order? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { return nil }

        guard let existingItem = item as? Data
        else {
            return nil
        }
        return Order.order(existingItem)
    }

    func clear() -> Bool {
        let query: [String: Any] = [kSecClass as String : kSecClassGenericPassword ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
