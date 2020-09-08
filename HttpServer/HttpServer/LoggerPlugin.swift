//
//  LoggerPlugin.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/4.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

class LoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        print("\n")
        print("------------------- 开始请求 -------------------")
        print("地址: ", target.baseURL.absoluteString + target.path)
        print("参数: ", target.task.parameters)
        print("类型: ", target.method)
        print("------------------- 开始请求 -------------------")
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let respose):
            let data = try? respose.mapString()
            print("\n")
            print("------------------- 开始结束 -------------------")
            print("地址: ", respose.request?.url?.absoluteString ?? "无")
            print("参数: ", target.task.parameters)
            print("类型: ", target.method)
            print("数据: ", data ?? "无")
            print("------------------- 开始结束 -------------------")
        case .failure(let error): break
//            print("LoggerPlugin", error)
        }
    }
}
