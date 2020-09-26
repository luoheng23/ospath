import XCTest
@testable import ospath

final class ospathTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ospath().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
