//
//  HttpResultHandler.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

/// 网络请求数据回调处理协议
///
/// 将闭包转为方法
protocol HttpResultHandler where Self: BaseViewController {
    associatedtype Element
    func resultHandler(_ result: Result<Element, HttpError>)
}
