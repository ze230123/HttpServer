//
//  UserApi.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

/// 用户信息相关Api
enum UserApi {
    /// 获取用户信息
    case info(id: Int)
}

extension UserApi: TargetType, MoyaAddable {
    var policy: CachePolicy {
        switch self {
        case .info:
            return .cache(CacheConfig(path: path, parameters: task.parameters, module: .other, expiry: .time(.month(1))))
        }
    }

    var task: Task {
        switch self {
        case let .info(id):
            let parameters: [String: Any] = [
                "numId": id,
                "isFillAreaName": true,
                "machineCode": MyUDID.share.getUDID(uid: "\(id)")
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var path: String {
        switch self {
        case .info:
            return "/Users/GetBrief"
        }
    }

    var method: Method {
        return .post
    }

    var baseURL: URL {
        return URL(string: "http://106.75.118.194:5100")!
    }
}
