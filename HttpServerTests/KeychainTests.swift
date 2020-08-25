//
//  KeychainTests.swift
//  HttpServerTests
//
//  Created by youzy01 on 2020/6/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import XCTest
import HttpServer

class KeychainTests: XCTestCase {
    let stored = OrderStored()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        _ = stored.clear()
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

    func testOrderSetTrue() {
        let order = Order(orderNo: "O10000000", iapOrderNo: "1234567", provinceId: 893, userId: 10010)
        let success = stored.set(order, for: order.iapOrderNo)
        XCTAssertFalse(order.iapOrderNo.isEmpty)
        XCTAssertTrue(success)
    }

    func testOrderUpdate() {
        var order = Order(orderNo: "O10000000", iapOrderNo: "1234567", provinceId: 893, userId: 10010)
        let success = stored.set(order, for: order.iapOrderNo)
        XCTAssertFalse(order.iapOrderNo.isEmpty)
        XCTAssertTrue(success)

        order.orderNo = "O10000012"
        let success2 = stored.set(order, for: order.iapOrderNo)
        XCTAssertTrue(success2)

        let value = stored.get(order.iapOrderNo)
        XCTAssertEqual(value?.orderNo, order.orderNo)
        XCTAssertEqual(value?.orderNo, "O10000012")
    }

    func testOrderGet() {
        let order = Order(orderNo: "O10000000", iapOrderNo: "1234567", provinceId: 893, userId: 10010)
        let success = stored.set(order, for: order.iapOrderNo)
        XCTAssertFalse(order.iapOrderNo.isEmpty)
        XCTAssertTrue(success)

        let order1 = stored.get("1234567")
        XCTAssertNotNil(order)
        XCTAssertEqual(order1?.orderNo, "O10000000")
        XCTAssertEqual(order1?.iapOrderNo, "1234567")
    }

    func testOrderDelete() {
        let order = Order(orderNo: "O10000000", iapOrderNo: "1234567", provinceId: 893, userId: 10010)
        let success = stored.set(order, for: order.iapOrderNo)
        XCTAssertFalse(order.iapOrderNo.isEmpty)
        XCTAssertTrue(success)

        let isDelete = stored.delete(order.iapOrderNo)
        XCTAssertTrue(isDelete)

        let order1 = stored.get(order.iapOrderNo)
        XCTAssertNil(order1)
    }

    func testTransformJsonEquatable() {
        for idx in (1...5) {
            let user1 = User(id: "12345678", numId: 987654, gender: .male)
            let json1 = user1.toJSONString(prettyPrint: true)
            let user2 = User(id: "12345678", numId: 987654, gender: .male)
            let json2 = user2.toJSONString(prettyPrint: true)
            print("\n")
            print("----------------- \(idx) -----------------")
            print(json1)
            print(json2)
            print("----------------- \(idx) -----------------")
            XCTAssertEqual(json1, json2)
        }
    }
}
