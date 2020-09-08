//
//  APIError.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya
import Alamofire

struct APIError: Error {
    var message: String
    var mode: Mode

    init(mode: Mode) {
        message = mode.title
        self.mode = mode
    }
}

extension APIError {
    enum Mode {
        /// http其他错误
        case httpOther
        /// 未找到缓存
        case noCache
        /// 请求过于频繁
        case overload
        /// 没有网络
        case noNetwork
        /// 您没有权限查看该数据
        case noAuthority
        /// 连接超时
        case timeout
        /// 无法连接主机地址
        case unknownHost
        /// 数据转换失败
        case dataMapping
        /// 模型转换失败
        case modelMapping
        /// 服务器返回错误信息
        case server(String)
        /// 未知错误
        case unknown(String)

        var detail: (title: String, content: String) {
            switch self {
            case .httpOther:        return ("HTTP其他错误", "")
            case .noCache:          return ("未找到缓存", "请连接网络后重试")
            case .overload:         return ("请求过于频繁", "请稍后再试")
            case .noNetwork:        return ("没有找到网络", "请检查网络后重试")
            case .noAuthority:      return ("您没有权限查看该数据", "")
            case .timeout:          return ("连接超时", "请检查网络后重试")
            case .unknownHost:      return ("无法连接主机地址", "")
            case .dataMapping:      return ("数据解析出错", "")
            case .modelMapping:     return ("数据模型转换失败", "")
            case .server(let msg):  return (msg, "")
            case .unknown(let msg): return (msg, "")
            }
        }

        var title: String {
            return detail.title
        }

        var content: String {
            return detail.content
        }
    }
}

/// 接口异常处理
class ApiException {
    static func handleException(_ error: Error) -> APIError {
        return error.asAPIError()
    }
}

fileprivate extension Error {
    func asAPIError() -> APIError {
        do {
            return try handler()
        } catch URLError.timedOut {
            return APIError(mode: .timeout)
        } catch URLError.notConnectedToInternet {
            return APIError(mode: .noNetwork)
        } catch {
            return APIError(mode: .unknown(error.localizedDescription))
        }
    }

    func handler() throws -> APIError {
        if let error = self as? APIError {
            return error
        }
        guard let moyaError = self as? MoyaError else {
            return APIError(mode: .unknown(localizedDescription))
        }

        switch moyaError {
        case .statusCode(let response):
            switch response.statusCode {
            case 408:
                return APIError(mode: .timeout)
            case 401:
                return APIError(mode: .noAuthority)
            case 403:
                return APIError(mode: .unknown(""))
            case 900:
                return APIError(mode: .unknown(""))
            default:
                let msg = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                return APIError(mode: .unknown(msg))
            }
        case .stringMapping, .jsonMapping, .imageMapping, .objectMapping:
            return APIError(mode: .dataMapping)
        case let .underlying(error as AFError, _):
            if let unerror = error.underlyingError {
                throw unerror
            }
            return APIError(mode: .unknown(error.localizedDescription))
        default:
            return APIError(mode: .unknown(moyaError.localizedDescription))
        }
    }
}
