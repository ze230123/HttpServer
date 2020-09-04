//
//  RequestCountHandler.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/7.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import GRDB

/// 请求频率处理
class RequestFrequencyHandler {
    let database: RequestFrequencyDatabase

    init() {
        let databaseURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("requestFrequency.sqlite")
        let dbQueue = try! DatabaseQueue(path: databaseURL.path)
        // Create the shared application database
        database = try! RequestFrequencyDatabase(dbQueue)
    }

    /// 检验一个请求是否无效
    /// - Parameters:
    ///   - api: 接口path
    ///   - parameter: 接口参数
    /// - Returns: true: 无效， false: 有效
    func invalid(api: String, parameter: String) -> Bool {
        let apiParameterCount = try! database.queryCount(api, parameter: parameter, date: Date(timeIntervalSinceNow: RequestFrequencyConfig.apiAndParameter.time))
        let apiCount = try! database.queryCount(api, date: Date(timeIntervalSinceNow: RequestFrequencyConfig.api.time))
        let allCount = try! database.queryCount(Date(timeIntervalSinceNow: RequestFrequencyConfig.all.time))

        if apiParameterCount > RequestFrequencyConfig.apiAndParameter.count {
            return true
        } else if apiCount > RequestFrequencyConfig.api.count {
            return true
        } else if allCount > RequestFrequencyConfig.all.count {
            return true
        }
        return false
    }

    func saveRecord(_ api: String, parameter: String) {
        try! database.saveRecord(api, parameter: parameter)
    }
}

struct RequestFrequency {
    let time: TimeInterval
    let count: Int

    static let zero = RequestFrequency(time: 0, count: 0)
}

struct RequestFrequencyConfig {
    // 同一接口 同一参数
    static private(set) var apiAndParameter: RequestFrequency = .zero
    // 同一接口
    static private(set) var api: RequestFrequency = .zero
    // 所有接口
    static private(set) var all: RequestFrequency = .zero

    static func setApiAndParameter(_ apiAndParameter: RequestFrequency) {
        self.apiAndParameter = apiAndParameter
    }

    static func setApi(_ api: RequestFrequency) {
        self.api = api
    }

    static func setAll(_ all: RequestFrequency) {
        self.all = all
    }
}

struct RequestFrequencyDatabase {
    private let dbQueue: DatabaseQueue

    /// Creates an AppDatabase and make sure the database schema is ready.
    init(_ dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        try migrator.migrate(dbQueue)
    }

    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/README.md#migrations
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createRequestRecord") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "requestRecord") { t in
                t.autoIncrementedPrimaryKey("id")
                // Sort player names in a localized case insensitive fashion by default
                // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
                t.column("api", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("parameter", .text).collate(.localizedCaseInsensitiveCompare)
                t.column("date", .date).notNull()
            }
        }
        return migrator
    }
}

extension RequestFrequencyDatabase {
    /// 保存请求记录
    /// - Parameters:
    ///   - api: 接口path
    ///   - parameter: 接口参数
    /// - Throws: 保存数据库引发的错误
    func saveRecord(_ api: String, parameter: String) throws {
        var item = RequestRecord(api: api, parameter: parameter)
        try dbQueue.write { db in
            try item.save(db)
        }
    }

    /// 保存请求记录
    /// - Parameters:
    ///   - api: 接口path
    ///   - parameter: 接口参数
    ///   - date: 接口调用时间
    /// - Throws: 保存数据库引发的错误
    func saveRecord(_ api: String, parameter: String, date: Date) throws {
        var item = RequestRecord(api: api, parameter: parameter, date: date)
        try dbQueue.write { db in
            try item.save(db)
        }
    }

    /// 查询记录数量
    /// - Parameters:
    ///   - api: 接口path
    ///   - parameter: 接口参数
    ///   - date: 接口请求时间
    /// - Throws: 查询数据库引发的错误
    /// - Returns: 符合条件的请求记录数量
    func queryCount(_ api: String, parameter: String, date: Date) throws -> Int {
        let apiColumn = Column("api")
        let parameterColumn = Column("parameter")
        let dateColumn = Column("date")

        return try dbQueue.read { (db) -> Int in
            return try RequestRecord.filter(apiColumn == api).filter(parameterColumn == parameter).filter(dateColumn > date).fetchCount(db)
        }
    }

    /// 查询记录数量
    /// - Parameters:
    ///   - api: 接口path
    ///   - date: 接口请求时间
    /// - Throws: 查询数据库引发的错误
    /// - Returns: 符合条件的请求记录数量
    func queryCount(_ api: String, date: Date) throws -> Int {
        let apiColumn = Column("api")
        let dateColumn = Column("date")

        return try dbQueue.read { (db) -> Int in
            return try RequestRecord.filter(apiColumn == api).filter(dateColumn > date).fetchCount(db)
        }
    }

    /// 查询记录数量
    /// - Parameter date: 接口请求时间
    /// - Throws: 查询数据库引发的错误
    /// - Returns: 符合条件的请求记录数量
    func queryCount(_ date: Date) throws -> Int {
        let dateColumn = Column("date")

        return try dbQueue.read { (db) -> Int in
            return try RequestRecord.filter(dateColumn > date).fetchCount(db)
        }
    }

    /// 删除全部记录
    /// - Throws: 删除数据库记录引发的错误
    func deleteAll() throws {
        try dbQueue.write { db in
            _ = try RequestRecord.deleteAll(db)
        }
    }
}

/// 网络链接请求记录
struct RequestRecord {
    var id: Int64?
    var api: String = ""
    var parameter: String = ""
    var date: Date = Date()

    init(api: String, parameter: String) {
        self.api = api
        self.parameter = parameter
    }

    init(api: String, parameter: String, date: Date) {
        self.api = api
        self.parameter = parameter
        self.date = date
    }
}

extension RequestRecord: Codable, FetchableRecord, MutablePersistableRecord, TableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let path = Column(CodingKeys.api)
        static let parameter = Column(CodingKeys.parameter)
        static let date = Column(CodingKeys.date)
    }

    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
