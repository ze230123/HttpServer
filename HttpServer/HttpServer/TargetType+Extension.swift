//
//  TargetType+Extension.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

extension TargetType {
    var sampleData: Data {
        return "".data(using: .utf8) ?? Data()
    }

    var headers: [String: String]? {
        return [
            "YouzyApp_Sign": ApiSignature.sign,
            "YouzyApp_ApiSign": ApiSignature.apiSign,
            "YouzyApp_DataSign": ApiSignature.dateSign,
            "YouzyApp_SuperSign": ApiSignature.superSign,
            "YouzyApp_FromSource": "iOS-\(1.0)",
            "Youzy-CurrentUserId": "123456"
        ]
    }
}
