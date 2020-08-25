//
//  ScoreApi.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/25.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

enum ScoreApi {
    /// 获取用户当前使用成绩信息
    case getByUser(numId: Int, proId: Int)
}

extension ScoreApi: TargetType, MoyaAddable {
    var policy: CachePolicy {
        switch self {
        case .getByUser:
//            return .cacheAndRequest(CacheConfig(path: path, parameters: task.parameters, module: .other, expiry: .time(.month(1))))
            return .firstCache(CacheConfig(path: path, parameters: task.parameters, module: .other, expiry: .time(.month(1))))
        }
    }

    var task: Task {
        switch self {
        case let .getByUser(numId, proId):
            let parameters: [String: Any] = [
                "userNumId": numId,
                "provinceNumId": proId,
                "isGaoKao": true,
                "isFillProvinceName": true
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var path: String {
        switch self {
        case .getByUser:
            return "/Users/Scores/GetByUserNumId"
        }
    }

    var method: Method {
        return .post
    }

    var baseURL: URL {
        return URL(string: "http://106.75.118.194:5100")!
    }
}
