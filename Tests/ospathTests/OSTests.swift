import XCTest

@testable import ospath

// TODO
final class OSTests: XCTestCase {

    func testStat() {
        let path = "README.md"
        do {
            let _ = try OS.stat(path)
        }
        catch {
            XCTAssertTrue(false)
        }
    }

    static var allTests = [
        ("testStat", testStat)
    ]
}
