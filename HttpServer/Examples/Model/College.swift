//
//  College.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import ObjectMapper

struct NewCollegeList: Mappable {
    var items: [NewCollegeModel] = []
    var totalCount: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        items   <- map["items"]
        totalCount   <- map["totalCount"]
    }
}

/// 大学model
struct NewCollegeModel: Mappable {
    var provinceName: String = ""
    var creation: String = ""
    var isProvincial: Int = 0
    var isSingleRecruit: Bool = false
    var isKey: Int = 0
    var hits: Int = 0
    var isGZDZ: Bool = false
    var maleRate: Int = 0
    var id: String = ""
    var cnName: String = ""
    var formatHits: String = ""
    var cityName: String = ""
    var education: Int = 0
    var bxcc: String = ""
    var plan: Int = 0
    var rankOfCn: Int = 0
    var majorRule: String = ""
    var pointsOfShuo: Int = 0
    var keyMajorNum: Int = 0
    var rankSummary: String = ""
    var nature: String = ""
    var line: Int = 0
    var pointsOfBo: Int = 0
    var logoId: Int = 0
    var nameUsedBefore: String = ""
    var logoUrl: String = ""
    var cityId: Int = 0
    var collegeRule: String = ""
    var educationId: Int = 0
    var isBTProvince: Int = 0
    var level: String = ""
    var isArt: Bool = false
    var type: Int = 0
    var rankOfWorld: Int = 0
    var employmentRate: String = ""
    var code: String = ""
    var isDependent: Int = 0
    var provinceId: Int = 0
    var enName: String = ""
    var numId: Int = 0
    var firstClass: String = ""
    var femaleRate: Int = 0
    var departmentNum: Int = 0
    var isCivilianRun: Int = 0
    var typeId: Int = 0
    var belong: String = ""
    var summary: String = ""
    var is985: Int = 0
    var shortName: String = ""
    var classify: String = ""
    var year: Int = 0
    var is211: Int = 0

    var tags: [String] = []

    var levels: [String] {
        return ["985", "双一流", "211"]
//        if tags.isEmpty {
//            return AppUtils.getCollegeLevels(is211: is211, is985: is985, firstClass: firstClass)
////            var arr: [String] = []
////            if is985 == 1 {
////                arr.append("985")
////            }
////            if is211 == 1 {
////                arr.append("211")
////            }
////            if !firstClass.isEmpty {
////                arr.append("双一流")
////            }
////            return arr
//        } else {
//            let filterArr = AppConstant.College.tagsFilter
//            let titles = tags.filter { (item) -> Bool in
//                return filterArr.contains(item)
//            }
//            return titles
//        }
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        provinceName   <- map["provinceName"]
        creation   <- map["creation"]
        isProvincial   <- map["isProvincial"]
        isSingleRecruit   <- map["isSingleRecruit"]
        isKey   <- map["isKey"]
        hits   <- map["hits"]
        isGZDZ   <- map["isGZDZ"]
        maleRate   <- map["maleRate"]
        id   <- map["id"]
        cnName   <- map["cnName"]
        formatHits   <- map["formatHits"]
        cityName   <- map["cityName"]
        education   <- map["education"]
        bxcc   <- map["bxcc"]
        plan   <- map["plan"]
        rankOfCn   <- map["rankOfCn"]
        majorRule   <- map["majorRule"]
        pointsOfShuo   <- map["pointsOfShuo"]
        keyMajorNum   <- map["keyMajorNum"]
        rankSummary   <- map["rankSummary"]
        nature   <- map["nature"]
        line   <- map["line"]
        pointsOfBo   <- map["pointsOfBo"]
        logoId   <- map["logoId"]
        nameUsedBefore   <- map["nameUsedBefore"]
        logoUrl   <- map["logoUrl"]
        cityId   <- map["cityId"]
        collegeRule   <- map["collegeRule"]
        educationId   <- map["educationId"]
        isBTProvince   <- map["isBTProvince"]
        level   <- map["level"]
        isArt   <- map["isArt"]
        type   <- map["type"]
        rankOfWorld   <- map["rankOfWorld"]
        employmentRate   <- map["employmentRate"]
        code   <- map["code"]
        isDependent   <- map["isDependent"]
        provinceId   <- map["provinceId"]
        enName   <- map["enName"]
        numId   <- map["numId"]
        firstClass   <- map["firstClass"]
        femaleRate   <- map["femaleRate"]
        departmentNum   <- map["departmentNum"]
        isCivilianRun   <- map["isCivilianRun"]
        typeId   <- map["typeId"]
        belong   <- map["belong"]
        summary   <- map["summary"]
        is985   <- map["is985"]
        shortName   <- map["shortName"]
        classify   <- map["classify"]
        year   <- map["year"]
        is211   <- map["is211"]

        provinceName = provinceName.replacingOccurrences(of: "S - ", with: "")
    }

//    init(item: HotCollegeList) {
//        logoUrl = item.logoUrl
//        provinceName = item.provinceName
//        code = item.code
//        numId = item.collegeId
//        classify = item.classify
//        cnName = item.collegeName
//        type = item.typeInt
//        tags = item.tags
//        belong = item.belong
//    }
}



/// 院校列表专用数据模型（找大学列表、通用搜索）
struct CollegeListModel {
    /// 院校名
    var name: String
    /// 标签：985、211等
    var levels: [String]
    /// 院校所在省份名
    var provinceName: String
    /// 院校logo
    var logoUrl: String
    /// 类别：综合、艺术、医药等
    var classify: String
    /// 所属部门
    var belong: String
    /// 院校类型：公办、民办、中外/港澳
    var type: String

    var code: String
    var numId: Int

//    init(item: HotCollegeList) {
//        logoUrl = item.logoUrl
//        provinceName = item.provinceName
//        code = item.code
//        numId = item.collegeId
//        classify = item.classify
//        name = item.collegeName
//        type = AppUtils.getCollegeType(item.typeInt)
//
//        belong = item.belong
//
//        let filterArr = AppConstant.College.tagsFilter
//        levels = item.tags.filter { (item) -> Bool in
//            return filterArr.contains(item)
//        }
//    }

    init(item: NewCollegeModel) {
        logoUrl = item.logoUrl
        provinceName = item.provinceName
        code = item.code
        numId = item.numId
        classify = item.classify
        name = item.cnName

        type = "公办"
//        type = AppUtils.getCollegeType(item.type)

        belong = item.belong
        levels = item.levels
    }

//    init(item: CollegeSearchItems) {
//        logoUrl = item.logoUrl
//        provinceName = item.provinceName
//        code = ""
//        numId = item.numId
//        classify = item.classify
//        name = item.cnName
//        type = AppUtils.getCollegeType(item.type)
//
//        belong = item.belong
//        levels = item.levels
//    }
}
