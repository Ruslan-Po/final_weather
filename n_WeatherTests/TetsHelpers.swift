import Foundation
import XCTest
@testable import n_Weather

extension NSError {
    static func testError(domain: String = "TestDomain", code: Int = 1, description: String = "Test error") -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: description
        ])
    }
}

struct TestHelper {
    static func wait(seconds: TimeInterval = 0.1) {
        let expectation = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: seconds + 1.0)
    }
}
