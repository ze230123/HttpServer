//
//  MyUDID.swift
//  Network
//
//  Created by youzy01 on 2019/8/9.
//  Copyright © 2019 youzy. All rights reserved.
//

import Foundation

class MyUDID {
    static let share = MyUDID()

    func clear() {
        UserDefaults.standard.set("", forKey: "uid")
    }

    func verify(code: String, uid: String) -> Bool {
        let udid = getUDID(uid: uid)
        return udid == code
    }

    func getDBPwd(uid: String) -> String {
        let str = getUDID(uid: uid) + uid
        return String(str.md5.lowercased().prefix(6))
    }

    func getUDID(uid: String) -> String {
        let defauts = UserDefaults.standard

        var udid = defauts.string(forKey: "uid") ?? ""
        var salt = ""

        if udid.isEmpty {
//            Logger.debug("udid 为空")
            salt = UUID().uuidString.md5
            let data = (uid.md5 + salt).data(using: .utf8)
            udid = data?.encode.toString() ?? ""
        } else {
//            Logger.debug("udid 有值 : \(udid)")
            udid = decodeUdid(udid)
//            Logger.debug(udid)
//            Logger.debug(uid.MD5)
            salt = String(udid.suffix(32))
//            Logger.debug(salt)
            let subUid = String(udid.prefix(32))
            let uidMd5 = uid.md5
            if subUid != uidMd5 {
//                Logger.debug("重新生成")
                salt = UUID().uuidString.md5
                let data = (uid.md5 + salt).data(using: .utf8)
                udid = data?.encode.toString() ?? ""
            } else {
//                Logger.debug("重新加密")
                udid = udid.data(using: .utf8)?.encode.toString() ?? ""
            }
        }
        UserDefaults.standard.set(udid, forKey: "uid")
//        saveUdid = udid
        return salt
    }

    func salt() -> String {
        return UUID().uuidString.md5
    }

    func encodeUdid(uid: String) -> String {
        let data = (uid.md5 + salt()).data(using: .utf8)
        return data?.encode.toString() ?? ""
    }

    func decodeUdid(_ udid: String) -> String {
        return udid.data(using: .utf8)?.decode.toString() ?? "udid解析失败"
    }
}
