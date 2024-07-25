import XCTest
@testable import walkbook

final class NonceUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRandomNonceStringLength() {
            let length = 32
            let nonce = NonceUtils.randomNonceString(length: length)
            XCTAssertEqual(nonce.count, length, "Nonce length should be \(length)")
        }
        
        func testRandomNonceStringCharacters() {
            let length = 32
            let charset = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            let nonce = NonceUtils.randomNonceString(length: length)
            
            XCTAssertTrue(nonce.unicodeScalars.allSatisfy { charset.contains($0) }, "Nonce contains invalid characters")
        }
        
        func testRandomNonceStringUnique() {
            let nonce1 = NonceUtils.randomNonceString()
            let nonce2 = NonceUtils.randomNonceString()
            
            XCTAssertNotEqual(nonce1, nonce2, "Nonces should be unique")
        }

}
