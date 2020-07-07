//
//  RequestCountHandler.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/7.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import GRDB

class RequestFrequencyHandler {
    let database: RequestFrequencyDatabase

    init() {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        let dbQueue = try! DatabaseQueue(path: databaseURL.path)
        // Create the shared application database
        database = try! RequestFrequencyDatabase(dbQueue)
    }

    func valid(api: String, parameter: String) -> Bool {
        return true
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
                t.column("path", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("parameter", .text)
                t.column("date", .date).notNull()
            }
        }
        return migrator
    }
}

extension RequestFrequencyDatabase {
    func saveRecord(_ record: RequestRecord) {
    }
}


/// 网络链接请求记录
struct RequestRecord {
    var id: Int64?
    var path: String = ""
    var parameter: String = ""
    var date: Date = Date()

    init(path: String) {
        self.path = path
    }

    init(path: String, date: Date) {
        self.path = path
        self.date = date
    }
}

extension RequestRecord: Codable, FetchableRecord, MutablePersistableRecord, TableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let path = Column(CodingKeys.path)
        static let parameter = Column(CodingKeys.parameter)
        static let date = Column(CodingKeys.date)
    }

    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
