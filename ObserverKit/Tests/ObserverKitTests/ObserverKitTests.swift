import XCTest
@testable import ObserverKit

final class ObserverKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ObserverKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
