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
    
    func test_SignInButton_탭할_경우_SignInView가_보이는지() throws {
        let signInBtn = app.buttons["signInButton"]
        signInBtn.tap()
        
        let signInView = app.otherElements["signInView"]
        XCTAssertTrue(signInView.exists, "SignInView가 표시되지 않습니다.")
        
        let googleSignInButton = app.buttons["googleSignInButton"]
        XCTAssertTrue(googleSignInButton.exists, "구글 로그인 버튼이 표시되야 합니다.")
        XCTAssertTrue(googleSignInButton.isHittable, "구글 로그인 버튼을 누를 수 없습니다.")
        
        let kakaoSignInButton = app.buttons["kakaoSignInButton"]
        XCTAssertTrue(kakaoSignInButton.exists, "카카오 로그인 버튼이 표시되어야 합니다.")
        XCTAssertTrue(kakaoSignInButton.isHittable, "카카오 로그인 버튼을 누를 수 없습니다.")
        
        let naverSignInButton = app.buttons["naverSignInButton"]
        XCTAssertTrue(naverSignInButton.exists, "네이버 로그인 버튼이 표시되어야 합니다.")
        XCTAssertTrue(naverSignInButton.isHittable, "네이버 로그인 버튼을 누를 수 없습니다.")
        
        let appleSignInButton = app.buttons["appleSignInButton"]
        XCTAssertTrue(appleSignInButton.exists, "애플 로그인 버튼이 표시되어야 합니다.")
        XCTAssertTrue(appleSignInButton.isHittable, "애플 로그인 버튼을 누를 수 없습니다.")
    }
}
