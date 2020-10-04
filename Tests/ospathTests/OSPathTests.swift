import XCTest

@testable import ospath

// TODO
final class OSPathTests: XCTestCase {

    func test() {
        XCTAssertEqual(
            OSPath.commonpath(["/usr//local", "//usr/local"]),
            "/usr/local"
        )
    }

    static var allTests = [
        ("test", test)
    ]
}
