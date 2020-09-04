//
//  ApiException.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

/// 接口异常处理
class ApiException {
    static func handleException(_ error: Error) -> HttpError {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let reponse):
                if reponse.statusCode == 408 {
                    return HttpError.timeout
                } else if reponse.statusCode == 401 {
                    return HttpError.noAuthority
                } else {
                    return HttpError.noNetwork
                }
            case .stringMapping, .jsonMapping, .imageMapping, .objectMapping:
                return HttpError.dataMapping
            case let .underlying(error, _):
                return HttpError.message(error.localizedDescription)
            default:
                return HttpError.requestMapping
            }
        } else if let httpError = error as? HttpError {
            return httpError
        } else {
            return .unknown
        }
    }
}
