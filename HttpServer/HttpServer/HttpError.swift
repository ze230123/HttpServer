//
//  HttpError.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import Alamofire

//OVERLOAD("请求过于频繁", "请稍后再试"),
//NO_CACHE("未找到缓存", "请连接网络后重试"),
//NO_NETWORK("没有找到网络", "请检查网络后重试"),
//NO_AUTHORITY("您没有权限查看该数据",null ),
//
//SINGNATURE_FAILURE_TIME("当前系统时间不正确", "请设置成标准北京时间后重试"),
//SINGNATURE_FAILURE_SSL("证书签名失败", null),
//
//CONNECT_TIME_OUT("连接超时", "请检查网络后重试"),
//UNKNOWN_HOST("无法连接主机地址", null),
//
//SERVER_NULL("服务器返回为空", null, 666),

enum HttpError: Error {
    /// 未知错误
    case unknown
    /// 连接超时
    case timeout
    /// 请求过于频繁
    case frequently
    /// 未找到缓存
    case noCache
    /// 没有网络
    case noNetwork
    /// 您没有权限查看该数据
    case noAuthority
    /// 无法连接主机地址
    case unknownHost
    /// 接口报错信息
    case message(String)

    case objectMapping(jsonString: String, object: String)
    /// 数据转换失败
    case dataMapping
    /// 转换URLRequest错误
    case requestMapping
}
