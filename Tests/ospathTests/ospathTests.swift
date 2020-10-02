import XCTest
@testable import ospath

final class PosixPathTests: XCTestCase {

    func testIsabs() {
        XCTAssertEqual(PosixPath.isabs(""), false)
        XCTAssertEqual(PosixPath.isabs("/"), true)
        XCTAssertEqual(PosixPath.isabs("/foo"), true)
        XCTAssertEqual(PosixPath.isabs("/foo/bar"), true)
        XCTAssertEqual(PosixPath.isabs("foo/bar"), false)
    }

    func testJoin() {
        XCTAssertEqual(PosixPath.join("/foo", "bar", "/bar", "baz"),
                         "/bar/baz")
        XCTAssertEqual(PosixPath.join("/foo", "bar", "baz"), "/foo/bar/baz")
        XCTAssertEqual(PosixPath.join("/foo/", "bar/", "baz/"),
                         "/foo/bar/baz/")
    }

    func testSplit() {
        XCTAssert(PosixPath.split("/foo/bar") == ("/foo", "bar"))
        XCTAssert(PosixPath.split("/") == ("/", ""))
        XCTAssert(PosixPath.split("foo") == ("", "foo"))
        XCTAssert(PosixPath.split("////foo") == ("////", "foo"))
        XCTAssert(PosixPath.split("//foo//bar") == ("//foo", "bar"))
    }

    static var allTests = [
        ("testIsabs", testIsabs),
        ("testJoin", testJoin),
        ("testSplit", testSplit),
    ]
}
