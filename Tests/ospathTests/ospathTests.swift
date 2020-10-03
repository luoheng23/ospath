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

    func splitextTest(_ path: String, _ filename: String, _ ext: String) {
        XCTAssert(PosixPath.splitext(path) == (filename, ext))
        XCTAssert(PosixPath.splitext("/" + path) == ("/" + filename, ext))
        XCTAssert(PosixPath.splitext("abc/" + path) ==
                         ("abc/" + filename, ext))
        XCTAssert(PosixPath.splitext("abc.def/" + path) ==
                         ("abc.def/" + filename, ext))
        XCTAssert(PosixPath.splitext("/abc.def/" + path) ==
                         ("/abc.def/" + filename, ext))
        XCTAssert(PosixPath.splitext(path + "/") ==
                         (filename + ext + "/", ""))
    }

    func testSplitext() {
        splitextTest("foo.bar", "foo", ".bar")
        splitextTest("foo.boo.bar", "foo.boo", ".bar")
        splitextTest("foo.boo.biff.bar", "foo.boo.biff", ".bar")
        splitextTest(".csh.rc", ".csh", ".rc")
        splitextTest("nodots", "nodots", "")
        splitextTest(".cshrc", ".cshrc", "")
        splitextTest("...manydots", "...manydots", "")
        splitextTest("...manydots.ext", "...manydots", ".ext")
        splitextTest(".", ".", "")
        splitextTest("..", "..", "")
        splitextTest("........", "........", "")
        splitextTest("", "", "")
    }

    func testBasename() {
        XCTAssertEqual(PosixPath.basename("/foo/bar"), "bar")
        XCTAssertEqual(PosixPath.basename("/"), "")
        XCTAssertEqual(PosixPath.basename("foo"), "foo")
        XCTAssertEqual(PosixPath.basename("////foo"), "foo")
        XCTAssertEqual(PosixPath.basename("//foo//bar"), "bar")
    }

    func testDirname() {
        XCTAssertEqual(PosixPath.dirname("/foo/bar"), "/foo")
        XCTAssertEqual(PosixPath.dirname("/"), "/")
        XCTAssertEqual(PosixPath.dirname("foo"), "")
        XCTAssertEqual(PosixPath.dirname("////foo"), "////")
        XCTAssertEqual(PosixPath.dirname("//foo//bar"), "//foo")
    }

    func testIslink() {
    }

    static var allTests = [
        ("testIsabs", testIsabs),
        ("testJoin", testJoin),
        ("testSplit", testSplit),
        ("testSplitext", testSplitext),
        ("testBasename", testBasename),
        ("testDirname", testDirname),
        ("testIslink", testIslink),
    ]
}
