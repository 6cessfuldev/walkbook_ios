//
//  ViewControllerUITests.swift
//  walkbookUITests
//
//  Created by 육성민 on 7/12/24.
//

import XCTest

class ViewControllerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    func testLabelExists() throws {
        let app = XCUIApplication()
        let label = app.staticTexts["초기세팅 테스트"]
        
        XCTAssertTrue(label.exists)
    }

    func testLabelText() throws {
        let app = XCUIApplication()
        let label = app.staticTexts["초기세팅 테스트"]
        
        XCTAssertEqual(label.label, "초기세팅 테스트")
    }

    func testLabelPosition() throws {
        let app = XCUIApplication()
        let label = app.staticTexts["초기세팅 테스트"]
        
        XCTAssertTrue(label.exists)
        
        let expectedCenterX = app.frame.midX
        let expectedBottomY = app.frame.midY - 50
        
        XCTAssertEqual(label.frame.midX, expectedCenterX, accuracy: 1.0)
        XCTAssertEqual(label.frame.maxY, expectedBottomY, accuracy: 1.0)
    }
}
