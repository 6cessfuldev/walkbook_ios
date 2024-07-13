//
//  AuthenticationVCUITest.swift
//  walkbookUITests
//
//  Created by 육성민 on 7/14/24.
//

import XCTest

final class AuthenticationVCUITest: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_ChooseLoginView가_화면에_보이는지테스트() throws {
        let chooseLoginView = app.otherElements["chooseLoginView"]
        XCTAssert(chooseLoginView.exists)
    }
    
    func test_SignInButton이_보이는지_테스트() throws {
        let signInButton = app.buttons["signInButton"]
        XCTAssert(signInButton.exists)
        XCTAssertEqual(signInButton.label, "로그인 하시겠습니까?")
    }
    
    func test_SignUpButton이_보이는지_테스트() throws {
        let signUpButton = app.buttons["signUpButton"]
        XCTAssert(signUpButton.exists)
        XCTAssertEqual(signUpButton.label, "신규 가입하시겠습니까?")
    }
    
    func test_SignInButton_탭할_경우_SignUpButton과SignInButton_사라지는지() throws {
        let signInBtn = app.buttons["signInButton"]
        XCTAssert(signInBtn.exists)
        
        signInBtn.tap()
        
        XCTAssert(!signInBtn.isHittable)
    }
    
    func test_SignUpButton_탭할_경우_SignUpButton과SignInButton_사라지는지() throws {
        let signUpBtn = app.buttons["signUpButton"]
        XCTAssert(signUpBtn.exists)
        
        signUpBtn.tap()
        
        XCTAssert(!signUpBtn.isHittable)
    }
}
