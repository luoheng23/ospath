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
    XCTAssertEqual(
      PosixPath.join("/foo", "bar", "/bar", "baz"),
      "/bar/baz")
    XCTAssertEqual(PosixPath.join("/foo", "bar", "baz"), "/foo/bar/baz")
    XCTAssertEqual(
      PosixPath.join("/foo/", "bar/", "baz/"),
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
    XCTAssert(PosixPath.splitext("abc/" + path) == ("abc/" + filename, ext))
    XCTAssert(PosixPath.splitext("abc.def/" + path) == ("abc.def/" + filename, ext))
    XCTAssert(PosixPath.splitext("/abc.def/" + path) == ("/abc.def/" + filename, ext))
    XCTAssert(PosixPath.splitext(path + "/") == (filename + ext + "/", ""))
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
    let filename = "sdafsdfhdsufhisfu232u3fjdsjhfksfs"
    let newfile = filename + "1"
    let link = filename + "2"
    _ = try? OS.remove(newfile)
    _ = try? OS.remove(link)
    XCTAssertEqual(PosixPath.islink(newfile), false)
    XCTAssertEqual(PosixPath.lexists(link), false)
    XCTAssertEqual(PosixPath.islink(newfile), false)

    if OS.open(newfile) {
      _ = try? OS.symlink(newfile, link)
      XCTAssertEqual(PosixPath.islink(link), true)
      _ = try? OS.remove(newfile)
      XCTAssertEqual(PosixPath.islink(link), true)
      XCTAssertEqual(PosixPath.exists(link), false)
      XCTAssertEqual(PosixPath.lexists(link), true)
      _ = try? OS.remove(link)
    }
  }

  func testIsfile() {
    XCTAssertTrue(PosixPath.isfile("README.md"))
    XCTAssertFalse(PosixPath.isfile("Sources"))
    XCTAssertFalse(PosixPath.isfile("Source"))
  }

  func testIsdir() {
    XCTAssertFalse(PosixPath.isdir("README.md"))
    XCTAssertFalse(PosixPath.isdir("README.mds"))
    XCTAssertTrue(PosixPath.isdir("Sources"))
  }

  func testIsmount() {
    // TODO need more tests
    XCTAssertTrue(PosixPath.ismount("/"))
  }

  func testGetsize() {
    // if LICENSE changed, this test will fail
    let filename = "LICENSE"
    let size = 1064
    XCTAssertEqual(PosixPath.getsize(filename), size)
  }

  func testExpanduser() {
    XCTAssertEqual(PosixPath.expanduser("foo"), "foo")
    let env = ProcessInfo.processInfo.environment
    XCTAssertEqual(PosixPath.expanduser("~"), env["HOME"] ?? "")
  }

  func testNormpath() {
    XCTAssertEqual(PosixPath.normpath(""), ".")
    XCTAssertEqual(PosixPath.normpath("/"), "/")
    XCTAssertEqual(PosixPath.normpath("//"), "//")
    XCTAssertEqual(PosixPath.normpath("///"), "/")
    XCTAssertEqual(PosixPath.normpath("///foo/.//bar//"), "/foo/bar")
    XCTAssertEqual(
      PosixPath.normpath("///foo/.//bar//.//..//.//baz"),
      "/foo/baz")
    XCTAssertEqual(PosixPath.normpath("///..//./foo/.//bar"), "/foo/bar")
  }

  func testRealpath() {
    XCTAssertEqual(PosixPath.realpath("."), OS.getcwd())
    XCTAssertEqual(PosixPath.realpath("./."), OS.getcwd())
    XCTAssertEqual(PosixPath.realpath(".."), PosixPath.dirname(OS.getcwd()))
    XCTAssertEqual(PosixPath.realpath("../.."), PosixPath.dirname(PosixPath.dirname(OS.getcwd())))
    XCTAssertEqual(
      PosixPath.realpath([String](repeating: "..", count: 100).joined(separator: "/")), "/")
    XCTAssertEqual(
      PosixPath.realpath([String](repeating: ".", count: 100).joined(separator: "/")), OS.getcwd())
  }

  func testRealpathBasic() {
    let filename = "sdafsdfhdsufhisfu232u3fjds"
    let newfile = filename + "1"
    let link = filename + "2"
    _ = try? OS.remove(newfile)
    _ = try? OS.remove(link)

    if OS.open(newfile) {
      _ = try? OS.symlink(newfile, link)
      XCTAssertEqual(PosixPath.realpath(link), PosixPath.abspath(newfile))
      _ = try? OS.remove(newfile)
      _ = try? OS.remove(link)
    }
  }

  func testCommonpath() {
    XCTAssertEqual(PosixPath.commonpath(["/usr/local"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/usr/local", "/usr/local"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/usr/local/", "/usr/local"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/usr/local/", "/usr/local/"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/usr//local", "//usr/local"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/usr/./local", "/./usr/local"]), "/usr/local")
    XCTAssertEqual(PosixPath.commonpath(["/", "/dev"]), "/")
    XCTAssertEqual(PosixPath.commonpath(["/usr", "/dev"]), "/")
    XCTAssertEqual(PosixPath.commonpath(["/usr/lib/", "/usr/lib/python3"]), "/usr/lib")
    XCTAssertEqual(PosixPath.commonpath(["/usr/lib/", "/usr/lib64/"]), "/usr")

    XCTAssertEqual(PosixPath.commonpath(["/usr/lib", "/usr/lib64"]), "/usr")
    XCTAssertEqual(PosixPath.commonpath(["/usr/lib/", "/usr/lib64"]), "/usr")

    XCTAssertEqual(PosixPath.commonpath(["spam"]), "spam")
    XCTAssertEqual(PosixPath.commonpath(["spam", "spam"]), "spam")
    XCTAssertEqual(PosixPath.commonpath(["spam", "alot"]), "")
    XCTAssertEqual(PosixPath.commonpath(["and/jam", "and/spam"]), "and")
    XCTAssertEqual(PosixPath.commonpath(["and//jam", "and/spam//"]), "and")
    XCTAssertEqual(PosixPath.commonpath(["and/./jam", "./and/spam"]), "and")
    XCTAssertEqual(PosixPath.commonpath(["and/jam", "and/spam", "alot"]), "")
    XCTAssertEqual(PosixPath.commonpath(["and/jam", "and/spam", "and"]), "and")

    XCTAssertEqual(PosixPath.commonpath([""]), "")
    XCTAssertEqual(PosixPath.commonpath(["", "spam/alot"]), "")
  }

  func testCommonprefix() {
    XCTAssertEqual(
      PosixPath.commonprefix([]),
      ""
    )
    XCTAssertEqual(
      PosixPath.commonprefix(["/home/swenson/spam", "/home/swen/spam"]),
      "/home/swen"
    )
    XCTAssertEqual(
      PosixPath.commonprefix(["/home/swen/spam", "/home/swen/eggs"]),
      "/home/swen/"
    )
    XCTAssertEqual(
      PosixPath.commonprefix(["/home/swen/spam", "/home/swen/spam"]),
      "/home/swen/spam"
    )
    XCTAssertEqual(
      PosixPath.commonprefix(["home:swenson:spam", "home:swen:spam"]),
      "home:swen"
    )
    XCTAssertEqual(
      PosixPath.commonprefix([":home:swen:spam", ":home:swen:eggs"]),
      ":home:swen:"
    )
    XCTAssertEqual(
      PosixPath.commonprefix([":home:swen:spam", ":home:swen:spam"]),
      ":home:swen:spam"
    )
  }

  static var allTests = [
    ("testIsabs", testIsabs),
    ("testJoin", testJoin),
    ("testSplit", testSplit),
    ("testSplitext", testSplitext),
    ("testBasename", testBasename),
    ("testDirname", testDirname),
    ("testIslink", testIslink),
    ("testIsfile", testIsfile),
    ("testIsdir", testIsdir),
    ("testIsmount", testIsmount),
    ("testGetsize", testGetsize),
    ("testExpanduser", testExpanduser),
    ("testNormpath", testNormpath),
    ("testRealpath", testRealpath),
    ("testRealpathBasic", testRealpathBasic),
    ("testCommonpath", testCommonpath),
    ("testCommonprefix", testCommonprefix),
  ]
}
