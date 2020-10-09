import XCTest

@testable import ospath

final class ObjectPosixPathTests: XCTestCase {

    func testIsabs() {
        XCTAssertEqual(PosixPath("").isabs, false)
        XCTAssertEqual(PosixPath("/").isabs, true)
        XCTAssertEqual(PosixPath("/foo").isabs, true)
        XCTAssertEqual(PosixPath("/foo/bar").isabs, true)
        XCTAssertEqual(PosixPath("foo/bar").isabs, false)
    }

    func testJoin() {
        XCTAssertEqual(
            PosixPath("/foo").join("bar", "/bar", "baz"),
            PosixPath("/bar/baz")
        )
        XCTAssertEqual(
            PosixPath("/foo").join("bar", "baz"),
            PosixPath("/foo/bar/baz")
        )
        XCTAssertEqual(
            PosixPath("/foo/").join("bar/", "baz/"),
            PosixPath("/foo/bar/baz/")
        )
    }

    func testSplit() {
        XCTAssert(
            PosixPath("/foo/bar").split == (PosixPath("/foo"), PosixPath("bar"))
        )
        XCTAssert(PosixPath("/").split == (PosixPath("/"), PosixPath("")))
        XCTAssert(PosixPath("foo").split == (PosixPath(""), PosixPath("foo")))
        XCTAssert(
            PosixPath("////foo").split == (PosixPath("////"), PosixPath("foo"))
        )
        XCTAssert(
            PosixPath("//foo//bar").split == (
                PosixPath("//foo"), PosixPath("bar")
            )
        )
    }

    func splitextTest(_ path: String, _ filename: String, _ ext: String) {
        XCTAssert(
            PosixPath(path).splitext == (PosixPath(filename), PosixPath(ext))
        )
        XCTAssert(
            PosixPath("/" + path).splitext == (
                PosixPath("/" + filename), PosixPath(ext)
            )
        )
        XCTAssert(
            PosixPath("abc/" + path).splitext == (
                PosixPath("abc/" + filename), PosixPath(ext)
            )
        )
        XCTAssert(
            PosixPath("abc.def/" + path).splitext == (
                PosixPath("abc.def/" + filename), PosixPath(ext)
            )
        )
        XCTAssert(
            PosixPath("/abc.def/" + path).splitext == (
                PosixPath("/abc.def/" + filename), PosixPath(ext)
            )
        )
        XCTAssert(
            PosixPath(path + "/").splitext == (
                PosixPath(filename + ext + "/"), PosixPath("")
            )
        )
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
        XCTAssertEqual(PosixPath("/foo/bar").basename, PosixPath("bar"))
        XCTAssertEqual(PosixPath("/").basename, PosixPath(""))
        XCTAssertEqual(PosixPath("foo").basename, PosixPath("foo"))
        XCTAssertEqual(PosixPath("////foo").basename, PosixPath("foo"))
        XCTAssertEqual(PosixPath("//foo//bar").basename, PosixPath("bar"))
    }

    func testDirname() {
        XCTAssertEqual(PosixPath("/foo/bar").dirname, PosixPath("/foo"))
        XCTAssertEqual(PosixPath("/").dirname, PosixPath("/"))
        XCTAssertEqual(PosixPath("foo").dirname, PosixPath(""))
        XCTAssertEqual(PosixPath("////foo").dirname, PosixPath("////"))
        XCTAssertEqual(PosixPath("//foo//bar").dirname, PosixPath("//foo"))
    }

    func testIslink() {
        let filename = "sdafsdfhdsufhisfu232u3fjdsjhfksfs"
        let newfile = filename + "1"
        let link = filename + "2"
        _ = try? OS.remove(newfile)
        _ = try? OS.remove(link)
        let pathNewfile = PosixPath(newfile)
        let pathLink = PosixPath(link)
        XCTAssertEqual(pathNewfile.islink, false)
        XCTAssertEqual(pathLink.lexists, false)
        XCTAssertEqual(pathNewfile.exists, false)

        if OS.open(newfile) {
            _ = try? OS.symlink(newfile, link)
            XCTAssertEqual(pathLink.islink, true)
            _ = try? OS.remove(newfile)
            XCTAssertEqual(pathLink.islink, true)
            XCTAssertEqual(pathLink.exists, false)
            XCTAssertEqual(pathLink.lexists, true)
            _ = try? OS.remove(link)
        }
    }

    func testIsfile() {
        XCTAssertTrue(PosixPath("README.md").isfile)
        XCTAssertFalse(PosixPath("Sources").isfile)
        XCTAssertFalse(PosixPath("Source").isfile)
    }

    func testIsdir() {
        XCTAssertFalse(PosixPath("README.md").isdir)
        XCTAssertFalse(PosixPath("README.mds").isdir)
        XCTAssertTrue(PosixPath("Sources").isdir)
    }

    func testIsmount() {
        // TODO need more tests
        XCTAssertTrue(PosixPath("/").ismount)
    }

    func testGetsize() {
        // if LICENSE changed, this test will fail
        let filename = "LICENSE"
        let size = 1064
        XCTAssertEqual(PosixPath(filename).size, size)
    }

    func testExpanduser() {
        XCTAssertEqual(PosixPath("foo").expanduser, PosixPath("foo"))
        let env = ProcessInfo.processInfo.environment
        XCTAssertEqual(PosixPath("~").expanduser, PosixPath(env["HOME"] ?? ""))
    }

    func testNormpath() {
        XCTAssertEqual(PosixPath("").normpath, PosixPath("."))
        XCTAssertEqual(PosixPath("/").normpath, PosixPath("/"))
        XCTAssertEqual(PosixPath("//").normpath, PosixPath("//"))
        XCTAssertEqual(PosixPath("///").normpath, PosixPath("/"))
        XCTAssertEqual(
            PosixPath("///foo/.//bar//").normpath,
            PosixPath("/foo/bar")
        )
        XCTAssertEqual(
            PosixPath("///foo/.//bar//.//..//.//baz").normpath,
            PosixPath("/foo/baz")
        )
        XCTAssertEqual(
            PosixPath("///..//./foo/.//bar").normpath,
            PosixPath("/foo/bar")
        )
    }

    func testRealpath() {
        XCTAssertEqual(PosixPath(".").realpath, PosixPath(OS.getcwd()))
        XCTAssertEqual(PosixPath("./.").realpath, PosixPath(OS.getcwd()))
        XCTAssertEqual(PosixPath("..").realpath, PosixPath(OS.getcwd()).dirname)
        XCTAssertEqual(
            PosixPath("../..").realpath,
            (PosixPath(OS.getcwd()).dirname.dirname)
        )
        XCTAssertEqual(
            PosixPath(
                [String](repeating: "..", count: 100).joined(separator: "/")
            ).realpath,
            PosixPath("/")
        )
        XCTAssertEqual(
            PosixPath(
                [String](repeating: ".", count: 100).joined(separator: "/")
            ).realpath,
            PosixPath(OS.getcwd())
        )
    }

    func testRealpathBasic() {
        let filename = "sdafsdfhdsufhisfu232u3fjds"
        let newfile = filename + "1"
        let link = filename + "2"
        _ = try? OS.remove(newfile)
        _ = try? OS.remove(link)

        if OS.open(newfile) {
            _ = try? OS.symlink(newfile, link)
            XCTAssertEqual(
                PosixPath(link).realpath,
                PosixPath(newfile).realpath
            )
            _ = try? OS.remove(newfile)
            _ = try? OS.remove(link)
        }
    }

    func testCommonpath() {
        XCTAssertEqual(PosixPath.commonpath(["/usr/local"]), "/usr/local")
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/local", "/usr/local"]),
            "/usr/local"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/local/", "/usr/local"]),
            "/usr/local"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/local/", "/usr/local/"]),
            "/usr/local"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr//local", "//usr/local"]),
            "/usr/local"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/./local", "/./usr/local"]),
            "/usr/local"
        )
        XCTAssertEqual(PosixPath.commonpath(["/", "/dev"]), "/")
        XCTAssertEqual(PosixPath.commonpath(["/usr", "/dev"]), "/")
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/lib/", "/usr/lib/python3"]),
            "/usr/lib"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/lib/", "/usr/lib64/"]),
            "/usr"
        )

        XCTAssertEqual(
            PosixPath.commonpath(["/usr/lib", "/usr/lib64"]),
            "/usr"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["/usr/lib/", "/usr/lib64"]),
            "/usr"
        )

        XCTAssertEqual(PosixPath.commonpath(["spam"]), "spam")
        XCTAssertEqual(PosixPath.commonpath(["spam", "spam"]), "spam")
        XCTAssertEqual(PosixPath.commonpath(["spam", "alot"]), "")
        XCTAssertEqual(PosixPath.commonpath(["and/jam", "and/spam"]), "and")
        XCTAssertEqual(PosixPath.commonpath(["and//jam", "and/spam//"]), "and")
        XCTAssertEqual(
            PosixPath.commonpath(["and/./jam", "./and/spam"]),
            "and"
        )
        XCTAssertEqual(
            PosixPath.commonpath(["and/jam", "and/spam", "alot"]),
            ""
        )
        XCTAssertEqual(
            PosixPath.commonpath(["and/jam", "and/spam", "and"]),
            "and"
        )

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
