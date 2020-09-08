//
//  RequestFrequencyDatabaseTests.swift
//  HttpServerTests
//
//  Created by youzy01 on 2020/7/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import XCTest
import GRDB
//import HttpServer
//import SwiftyUserDefaults

class RequestFrequencyDatabaseTests: XCTestCase {

    var database: RequestFrequencyDatabase!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let databaseURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("requestFrequency.sqlite")
        print(databaseURL.path)
        let dbQueue = try DatabaseQueue(path: databaseURL.path)
        // Create the shared application database
        database = try RequestFrequencyDatabase(dbQueue)
    }

    override func tearDownWithError() throws {
        try database.deleteAll()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testAddItemToDatabase() throws {
        let api = "api_1"
        let parameter = "p_1"

        try database.saveRecord(api, parameter: parameter)
        let date = Date(timeIntervalSinceNow: -5)
        let count = try database.queryCount(api, parameter: parameter, date: date)
        XCTAssert(count == 1, "查询失败")
    }

    func testQueryApiParameterDate() throws {
        let api = "api_1"
        let parameter = "p_1"

        try database.saveRecord(api, parameter: parameter, date: Date(timeIntervalSinceNow: -60))
        try database.saveRecord(api, parameter: parameter)
        let date = Date(timeIntervalSinceNow: -5)
        let count = try database.queryCount(api, parameter: parameter, date: date)
        XCTAssert(count == 1, "查询失败")
    }

    func testQueryApiDate() throws {
        let api = "api_1"
        let parameter = "p_2"

        try database.saveRecord(api, parameter: "", date: Date(timeIntervalSinceNow: -10))
        try database.saveRecord(api, parameter: parameter)
        let date = Date(timeIntervalSinceNow: -20)
        let count = try database.queryCount(api, date: date)
        XCTAssert(count == 2, "查询失败")
    }

    func testQueryDate() throws {
        try database.saveRecord("api", parameter: "432", date: Date(timeIntervalSinceNow: -30))
        try database.saveRecord("api", parameter: "432", date: Date(timeIntervalSinceNow: -20))
        try database.saveRecord("543", parameter: "feaf", date: Date(timeIntervalSinceNow: -20))
        try database.saveRecord("3243", parameter: "feaf", date: Date(timeIntervalSinceNow: -10))
        try database.saveRecord("543", parameter: "", date: Date(timeIntervalSinceNow: -10))
        let date = Date(timeIntervalSinceNow: -40)
        let count = try database.queryCount(date)
        XCTAssert(count == 5, "查询失败")
    }
}
