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
