//
//  ApiSignature.swift
//  NetWork
//
//  Created by 泽i on 2018/7/30.
//  Copyright © 2018年 泽i. All rights reserved.
//

import Foundation
extension String {
    func substring(location: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: location)
        let endIndex = self.index(self.startIndex, offsetBy: location + length)
        let subStr = self[startIndex..<endIndex]
        return String(subStr)
    }
}

/// 眼神版验签
struct ApiSignature {
}

extension ApiSignature {
    static var sign: String {
        let map = [
            "0": "Z",
            "1": "O",
            "2": "T",
            "3": "t",
            "4": "F",
            "5": "f",
            "6": "S",
            "7": "s",
            "8": "E",
            "9": "N",
            "-": "L",
            ":": "D",
            " ": "B"
        ]
        let format = "yyyy-MM-dd HH:mm:ss:SSS"
        return signString(map, delimiter: "G", obfuscator: "C", format: format)
    }

    static var apiSign: String {
        let map = [
            "0": "L",
            "1": "l",
            "2": "V",
            "3": "v",
            "4": "R",
            "5": "r",
            "6": "Y",
            "7": "y",
            "8": "P",
            "9": "I",
            "-": "W",
            ":": "w",
            " ": "Q"
        ]
        let format = "MM-yyyy-HH dd-mm-ss"
        return signString(map, delimiter: "h", obfuscator: "U", format: format)
    }

    static var dateSign: String {
        let map = [
            "0": "P",
            "1": "O",
            "2": "I",
            "3": "U",
            "4": "Y",
            "5": "T",
            "6": "R",
            "7": "E",
            "8": "W",
            "9": "Q",
            "-": "A",
            ":": "S",
            " ": "s"
        ]
        let format = "HH:MM-yyyy:::dd-SSS-mm-ss"
        return signString(map, delimiter: "t", obfuscator: "T", format: format)
    }

    static var superSign: String {
        let map = [
            "0": "M",
            "1": "N",
            "2": "B",
            "3": "V",
            "4": "C",
            "5": "X",
            "6": "Z",
            "7": "L",
            "8": "K",
            "9": "J",
            "-": "H",
            ":": "G",
            " ": "F"
        ]
        let format = "mm-dd-SSS-ss"
        return signString(map, delimiter: "Q", obfuscator: "q", format: format)
    }

    static var oldSign: String {
        let map = [
            "0": "Z",
            "1": "O",
            "2": "T",
            "3": "t",
            "4": "F",
            "5": "f",
            "6": "S",
            "7": "s",
            "8": "E",
            "9": "N",
            "-": "L",
            ":": "D",
            " ": "B"
        ]
        let format = "yyyy-MM-dd HH:mm:ss"
        return signString(map, delimiter: "", obfuscator: "C", format: format)
    }
}

private extension ApiSignature {
    static func randomString(for range: Range<Int> = 1..<1000000000) -> String {
        let number = Int.random(in: range)
        return "\(number)"
    }

    static func signString(_ map: [String: String], delimiter: String, obfuscator: String, format: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = format

        var dateStr = formatter.string(from: date)
        var numberStr = randomString()
        for (key, value) in map {
            dateStr = dateStr.replacingOccurrences(of: key, with: value)
            numberStr = numberStr.replacingOccurrences(of: key, with: value)
        }

        var sign = dateStr
        if !delimiter.isEmpty {
            sign += delimiter + numberStr
        }
//        var sign = dateStr + delimiter + numberStr
        let count = Int.random(in: 1..<10)

        for _ in 0..<count {
            let location = Int(arc4random_uniform(UInt32(sign.count - 1)))
            let temp = sign.substring(location: location, length: 1)
            let range = sign.range(of: temp)
            sign = (sign as NSString).replacingCharacters(in: range, with: temp + obfuscator)
        }
        return sign
    }
}

private extension String {
    func range(of sub: String) -> NSRange {
        return (self as NSString).range(of: sub)
    }

    func substring(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
}
