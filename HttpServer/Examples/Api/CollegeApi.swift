//
//  CollegeApi.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

struct AllCollegeParameter {
    var pageIndex: Int = 1
    var pageSize: Int = 20

    var parameters: [String: Any] {
        return [
            "provinceIds": [],
            "levels": [
                "firstClass": false,
                "is211": false,
                "is985": false,
                "isKey": false,
                "isProvincial": false
            ],
            "classify": [],
            "natures": [],
            "arts": [],
            "isArt": false,
            "isBen": -1,
            "type": -1,
            "isSingleRecruit": false,
            "wordSegment": false,
            "keywords": "",
            "pageIndex": pageIndex,
            "pageSize": pageSize
        ]
    }
}

struct BannerParameter {
//    var versionId: Int = 0
    /// Banner类型（0=首页Banner，1=讲堂）
    var bannerType: Int = 0
    /// 版本类型（1=Pc，2=H5，3=安卓，4=Ios，5=安卓Ios共用）
    var versionType: Int = 0
    /// 0查询全部
    var count: Int = 0

    init() {}

    init(type: Int, count: Int) {
        self.bannerType = type
        self.count = count

        versionType = 4
    }
}

extension BannerParameter {
    // 首页Banner
    static var home = BannerParameter(type: 0, count: 5)
    /// 讲堂Banner
    static var course = BannerParameter(type: 1, count: 5)
    /// 研究报告首页Banner
    static var center = BannerParameter(type: 2, count: 5)
    /// 专家首页Banner
    static var expert = BannerParameter(type: 3, count: 5)
}

extension BannerParameter {
    var parameters: [String: Any] {
        return [
            "provinceNumId": 834,
            "bannerType": bannerType,
//            "versionType": versionType,
            "count": count
        ]
    }
}

enum CollegeApi {
    case all(AllCollegeParameter)

    case insert(id: Int, name: String)
    case delete(id: Int, name: String)

    case banner(BannerParameter)
}

extension CollegeApi: TargetType, MoyaAddable {
    var policy: CachePolicy {
        switch self {
        case .all:
            return .firstCache(CacheConfig(path: path, parameters: task.parameters, module: .college, expiry: .time(.day(1))))
        case .insert:
            return .none(CacheConfig(path: path, parameters: task.parameters))
        case .delete:
            return .none(CacheConfig(path: path, parameters: task.parameters))
        case .banner:
            return .firstCache(CacheConfig(path: path, parameters: task.parameters, module: .college, expiry: .time(.day(1))))
        }
    }

    var task: Task {
        switch self {
        case let .all(parameter):
            return .requestParameters(parameters: parameter.parameters, encoding: JSONEncoding.default)
        case let .insert(id, name):
            let parameters: [String: Any] = [
                "userNumId": 14077053,
                "colleges": [
                    [
                        "collegeId": id,
                        "collegeName": name
                    ]
                ]
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case let .delete(id, name):
            let parameters: [String: Any] = [
                "userNumId": 14077053,
                "colleges": [
                    [
                        "collegeId": id,
                        "collegeName": name
                    ]
                ]
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case let .banner(parameter):
            return .requestParameters(parameters: parameter.parameters, encoding: JSONEncoding.default)
        }
    }

    var path: String {
        switch self {
        case .all:
            return "Colleges/Query"
        case .insert:
            return "Users/Collection/College/Insert"
        case .delete:
            return "Users/Collection/College/Remove"
        case .banner:
            return "/Advertisement/NewBanners/Query"
        }
    }

    var method: Method {
        return .post
    }

    var baseURL: URL {
        switch self {
        case .insert, .delete, .banner:
            return URL(string: "http://106.75.118.194:5101")!
        default:
            return URL(string: "http://106.75.118.194:5001")!
        }
    }
}

