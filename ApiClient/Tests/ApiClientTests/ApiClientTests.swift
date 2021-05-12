import XCTest
@testable import ApiClient

final class ApiClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ApiClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
