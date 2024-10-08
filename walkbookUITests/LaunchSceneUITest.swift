//
//  LaunchSceneUITest.swift
//  walkbookUITests
//
//  Created by 육성민 on 7/14/24.
//

import XCTest

final class LaunchSceneUITest: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_런치화면_지속시간_테스트() throws {
        let authenticationVC = app.otherElements["authenticationVC"]
        
        let waiter = XCTWaiter()
        let startTime = Date()
        let timeout = 10.0
        let result = waiter.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == 1"), object: authenticationVC)], timeout: timeout)
        switch result {
        case .completed:
            let endTime = Date()
            let launchScreenDuration = endTime.timeIntervalSince(startTime)
            XCTAssertTrue(authenticationVC.isHittable)
            print(launchScreenDuration)
            XCTAssertGreaterThan(launchScreenDuration, 1.0, "런치화면 노출 시간은 1초 이하입니다.")
            XCTAssertLessThan(launchScreenDuration, 3.0, "런치화면 노출 시간은 3초 이상입니다.")
        default:
            XCTFail("\(timeout)초 동안 다음 화면으로 전환되지 않습니다.")
            break
        }
    }
}
