import XCTest

@testable import ospath

final class ObjectNTPathTests: XCTestCase {

    func testIsabs() {
        XCTAssertEqual(NTPath("c:\\").isabs, true)
        XCTAssertEqual(NTPath("\\\\conky\\mountpoint\\").isabs, true)
        XCTAssertEqual(NTPath("\\foo").isabs, true)
        XCTAssertEqual(NTPath("\\foo\\bar").isabs, true)
    }

    func testJoin() {
        XCTAssertEqual(NTPath(""), NTPath(""))
        XCTAssertEqual(NTPath("").join("", ""), NTPath(""))
        XCTAssertEqual(NTPath("a"), NTPath("a"))
        XCTAssertEqual(NTPath("/a"), NTPath("/a"))
        XCTAssertEqual(NTPath("\\a"), NTPath("\\a"))
        XCTAssertEqual(NTPath("a:"), NTPath("a:"))
        XCTAssertEqual(NTPath("a:").join("\\b"), NTPath("a:\\b"))
        XCTAssertEqual(NTPath("a").join("\\b"), NTPath("\\b"))
        XCTAssertEqual(NTPath("a").join("b", "c"), NTPath("a\\b\\c"))
        XCTAssertEqual(NTPath("a\\").join("b", "c"), NTPath("a\\b\\c"))
        XCTAssertEqual(NTPath("a").join("b\\", "c"), NTPath("a\\b\\c"))
        XCTAssertEqual(NTPath("a").join("b", "\\c"), NTPath("\\c"))
        XCTAssertEqual(NTPath("d:\\").join("\\pleep"), NTPath("d:\\pleep"))
        XCTAssertEqual(NTPath("d:\\").join("a", "b"), NTPath("d:\\a\\b"))

        XCTAssertEqual(NTPath("").join("a"), NTPath("a"))
        XCTAssertEqual(NTPath("").join("", "", "", "a"), NTPath("a"))
        XCTAssertEqual(NTPath("a").join(""), NTPath("a\\"))
        XCTAssertEqual(NTPath("a").join("", "", "", ""), NTPath("a\\"))
        XCTAssertEqual(NTPath("a\\").join(""), NTPath("a\\"))
        XCTAssertEqual(NTPath("a\\").join("", "", "", ""), NTPath("a\\"))
        XCTAssertEqual(NTPath("a/").join(""), NTPath("a/"))

        XCTAssertEqual(NTPath("a/b").join("x/y"), NTPath("a/b\\x/y"))
        XCTAssertEqual(NTPath("/a/b").join("x/y"), NTPath("/a/b\\x/y"))
        XCTAssertEqual(NTPath("/a/b/").join("x/y"), NTPath("/a/b/x/y"))
        XCTAssertEqual(NTPath("c:").join("x/y"), NTPath("c:x/y"))
        XCTAssertEqual(NTPath("c:a/b").join("x/y"), NTPath("c:a/b\\x/y"))
        XCTAssertEqual(NTPath("c:a/b/").join("x/y"), NTPath("c:a/b/x/y"))
        XCTAssertEqual(NTPath("c:/").join("x/y"), NTPath("c:/x/y"))
        XCTAssertEqual(NTPath("c:/a/b").join("x/y"), NTPath("c:/a/b\\x/y"))
        XCTAssertEqual(NTPath("c:/a/b/").join("x/y"), NTPath("c:/a/b/x/y"))
        XCTAssertEqual(
            NTPath("//computer/share").join("x/y"),
            NTPath("//computer/share\\x/y")
        )
        XCTAssertEqual(
            NTPath("//computer/share/").join("x/y"),
            NTPath("//computer/share/x/y")
        )
        XCTAssertEqual(
            NTPath("//computer/share/a/b").join("x/y"),
            NTPath("//computer/share/a/b\\x/y")
        )

        XCTAssertEqual(NTPath("a/b").join("/x/y"), NTPath("/x/y"))
        XCTAssertEqual(NTPath("/a/b").join("/x/y"), NTPath("/x/y"))
        XCTAssertEqual(NTPath("c:").join("/x/y"), NTPath("c:/x/y"))
        XCTAssertEqual(NTPath("c:a/b").join("/x/y"), NTPath("c:/x/y"))
        XCTAssertEqual(NTPath("c:/").join("/x/y"), NTPath("c:/x/y"))
        XCTAssertEqual(NTPath("c:/a/b").join("/x/y"), NTPath("c:/x/y"))
        XCTAssertEqual(
            NTPath("//computer/share").join("/x/y"),
            NTPath("//computer/share/x/y")
        )
        XCTAssertEqual(
            NTPath("//computer/share/").join("/x/y"),
            NTPath("//computer/share/x/y")
        )
        XCTAssertEqual(
            NTPath("//computer/share/a").join("/x/y"),
            NTPath("//computer/share/x/y")
        )

        XCTAssertEqual(NTPath("c:").join("C:x/y"), NTPath("C:x/y"))
        XCTAssertEqual(NTPath("c:a/b").join("C:x/y"), NTPath("C:a/b\\x/y"))
        XCTAssertEqual(NTPath("c:/").join("C:x/y"), NTPath("C:/x/y"))
        XCTAssertEqual(NTPath("c:/a/b").join("C:x/y"), NTPath("C:/a/b\\x/y"))

        for x in [
            "", "a/b", "/a/b", "c:", "c:a/b", "c:/", "c:/a/b",
            "//computer/share", "//computer/share/", "//computer/share/a/b",
        ] {
            for y in [
                "d:", "d:x/y", "d:/", "d:/x/y",
                "//machine/common", "//machine/common/", "//machine/common/x/y",
            ] {
                XCTAssertEqual(NTPath(x).join(y), NTPath(y))
                XCTAssertEqual(NTPath(x) + y, NTPath(y))
                XCTAssertEqual(NTPath(x) + NTPath(y), NTPath(y))
                var z = NTPath(x)
                z += y
                XCTAssertEqual(z, NTPath(y))
                z = NTPath(x)
                z += NTPath(y)
                XCTAssertEqual(z, NTPath(y))
            }

        }

        XCTAssertEqual(
            NTPath("\\\\computer\\share\\").join("a", "b"),
            NTPath("\\\\computer\\share\\a\\b")
        )
        XCTAssertEqual(
            NTPath("\\\\computer\\share").join("a", "b"),
            NTPath("\\\\computer\\share\\a\\b")
        )
        XCTAssertEqual(
            NTPath("\\\\computer\\share").join("a\\b"),
            NTPath("\\\\computer\\share\\a\\b")
        )
        XCTAssertEqual(
            NTPath("//computer/share/").join("a", "b"),
            NTPath("//computer/share/a\\b")
        )
        XCTAssertEqual(
            NTPath("//computer/share").join("a", "b"),
            NTPath("//computer/share\\a\\b")
        )
        XCTAssertEqual(
            NTPath("//computer/share").join("a/b"),
            NTPath("//computer/share\\a/b")
        )
    }

    func testSplit() {
        XCTAssert(NTPath.split("c:\\foo\\ba") == ("c:\\foo", "ba"))
        XCTAssert(
            NTPath.split("\\\\conky\\mountpoint\\foo\\ba") == (
                "\\\\conky\\mountpoint\\foo", "ba"
            )
        )

        XCTAssert(NTPath.split("c:\\") == ("c:\\", ""))
        XCTAssert(
            NTPath.split("\\\\conky\\mountpoint\\") == (
                "\\\\conky\\mountpoint\\", ""
            )
        )

        XCTAssert(NTPath.split("c:/") == ("c:/", ""))
        XCTAssert(
            NTPath.split("//conky/mountpoint/") == ("//conky/mountpoint/", "")
        )
    }

    func testSplitext() {
        XCTAssert(NTPath.splitext("foo.ext") == ("foo", ".ext"))
        XCTAssert(NTPath.splitext("/foo/foo.ext") == ("/foo/foo", ".ext"))
        XCTAssert(NTPath.splitext(".ext") == (".ext", ""))
        XCTAssert(NTPath.splitext("\\foo.ext\\foo") == ("\\foo.ext\\foo", ""))
        XCTAssert(NTPath.splitext("foo.ext\\") == ("foo.ext\\", ""))
        XCTAssert(NTPath.splitext("") == ("", ""))
        XCTAssert(NTPath.splitext("foo.bar.ext") == ("foo.bar", ".ext"))
        XCTAssert(NTPath.splitext("xx/foo.bar.ext") == ("xx/foo.bar", ".ext"))
        XCTAssert(NTPath.splitext("xx\\foo.bar.ext") == ("xx\\foo.bar", ".ext"))
        XCTAssert(NTPath.splitext("c:a/b\\c.d") == ("c:a/b\\c", ".d"))
    }

    func testSplitdrive() {
        XCTAssert(NTPath.splitdrive("c:\\foo\\ba") == ("c:", "\\foo\\ba"))
        XCTAssert(NTPath.splitdrive("c:/foo/ba") == ("c:", "/foo/ba"))
        XCTAssert(
            NTPath.splitdrive("\\\\conky\\mountpoint\\foo\\ba") == (
                "\\\\conky\\mountpoint", "\\foo\\ba"
            )
        )
        XCTAssert(
            NTPath.splitdrive("//conky/mountpoint/foo/ba") == (
                "//conky/mountpoint", "/foo/ba"
            )
        )
        XCTAssert(
            NTPath.splitdrive("\\\\\\conky\\mountpoint\\foo\\ba") == (
                "", "\\\\\\conky\\mountpoint\\foo\\ba"
            )
        )
        XCTAssert(
            NTPath.splitdrive("///conky/mountpoint/foo/ba") == (
                "", "///conky/mountpoint/foo/ba"
            )
        )
        XCTAssert(
            NTPath.splitdrive("\\\\conky\\\\mountpoint\\foo\\ba") == (
                "", "\\\\conky\\\\mountpoint\\foo\\ba"
            )
        )
        XCTAssert(
            NTPath.splitdrive("//conky//mountpoint/foo/ba") == (
                "", "//conky//mountpoint/foo/ba"
            )
        )
    }

    func testBasename() {
        XCTAssertEqual(NTPath.basename("/foo/ba"), "ba")
        XCTAssertEqual(NTPath.basename("/"), "")
        XCTAssertEqual(NTPath.basename("foo"), "foo")
        XCTAssertEqual(NTPath.basename("////foo"), "foo")
        XCTAssertEqual(NTPath.basename("//foo//ba"), "ba")
    }

    func testDirname() {
        XCTAssertEqual(NTPath.dirname("/foo/ba"), "/foo")
        XCTAssertEqual(NTPath.dirname("/"), "/")
        XCTAssertEqual(NTPath.dirname("foo"), "")
        XCTAssertEqual(NTPath.dirname("////foo"), "////")
        XCTAssertEqual(NTPath.dirname("//foo//ba"), "//foo")
    }

    func testNormpath() {
        XCTAssertEqual(NTPath.normpath("A//////././//.//B"), "A\\B")
        XCTAssertEqual(NTPath.normpath("A/./B"), "A\\B")
        XCTAssertEqual(NTPath.normpath("A/foo/../B"), "A\\B")
        XCTAssertEqual(NTPath.normpath("C:A//B"), "C:A\\B")
        XCTAssertEqual(NTPath.normpath("D:A/./B"), "D:A\\B")
        XCTAssertEqual(NTPath.normpath("e:A/foo/../B"), "e:A\\B")

        XCTAssertEqual(NTPath.normpath("C:///A//B"), "C:\\A\\B")
        XCTAssertEqual(NTPath.normpath("D:///A/./B"), "D:\\A\\B")
        XCTAssertEqual(NTPath.normpath("e:///A/foo/../B"), "e:\\A\\B")

        XCTAssertEqual(NTPath.normpath(".."), "..")
        XCTAssertEqual(NTPath.normpath("."), ".")
        XCTAssertEqual(NTPath.normpath(""), ".")
        XCTAssertEqual(NTPath.normpath("/"), "\\")
        XCTAssertEqual(NTPath.normpath("c:/"), "c:\\")
        XCTAssertEqual(NTPath.normpath("/../.././.."), "\\")
        XCTAssertEqual(NTPath.normpath("c:/../../.."), "c:\\")
        XCTAssertEqual(NTPath.normpath("../.././.."), "..\\..\\..")
        XCTAssertEqual(NTPath.normpath("K:../.././.."), "K:..\\..\\..")
        XCTAssertEqual(NTPath.normpath("C:////a/b"), "C:\\a\\b")
        XCTAssertEqual(
            NTPath.normpath("//machine/share//a/b"),
            "\\\\machine\\share\\a\\b"
        )

        XCTAssertEqual(NTPath.normpath("\\\\.\\NUL"), "\\\\.\\NUL")

    }

    func testRealpath() {
        XCTAssertEqual(NTPath.realpath("."), NTPath.normpath(OS.getcwd()))
        XCTAssertEqual(NTPath.realpath("./."), NTPath.normpath(OS.getcwd()))
        XCTAssertEqual(
            NTPath.realpath(".."),
            NTPath.dirname(NTPath.normpath(OS.getcwd()))
        )
        XCTAssertEqual(
            NTPath.realpath("../.."),
            NTPath.dirname(NTPath.dirname(NTPath.normpath(OS.getcwd())))
        )
        XCTAssertEqual(
            NTPath.realpath(
                [String](repeating: ".", count: 100).joined(separator: "/")
            ),
            NTPath.normpath(OS.getcwd())
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
            XCTAssertEqual(NTPath.realpath(link), NTPath.abspath(newfile))
            _ = try? OS.remove(newfile)
            _ = try? OS.remove(link)
        }
    }

    func testCommonpath() {
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files", "C:\\Program Files"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files\\", "C:\\Program Files"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files\\", "C:\\Program Files\\"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\\\Program Files", "C:\\Program Files\\\\"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\.\\Program Files", "C:\\Program Files\\."]),
            "C:\\Program Files"
        )
        XCTAssertEqual(NTPath.commonpath(["C:\\", "C:\\bin"]), "C:\\")
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files", "C:\\bin"]),
            "C:\\"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files", "C:\\Program Files\\Bar"]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath([
                "C:\\Program Files\\Foo", "C:\\Program Files\\Bar",
            ]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files", "C:\\Projects"]),
            "C:\\"
        )
        XCTAssertEqual(
            NTPath.commonpath(["C:\\Program Files\\", "C:\\Projects"]),
            "C:\\"
        )

        XCTAssertEqual(
            NTPath.commonpath([
                "C:\\Program Files\\Foo", "C:/Program Files/Bar",
            ]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath([
                "C:\\Program Files\\Foo", "c:/program files/bar",
            ]),
            "C:\\Program Files"
        )
        XCTAssertEqual(
            NTPath.commonpath([
                "c:/program files/bar", "C:\\Program Files\\Foo",
            ]),
            "c:\\program files"
        )

    }

    func testCommonprefix() {
        XCTAssertEqual(
            NTPath.commonprefix([]),
            ""
        )
        XCTAssertEqual(
            NTPath.commonprefix(["/home/swenson/spam", "/home/swen/spam"]),
            "/home/swen"
        )
        XCTAssertEqual(
            NTPath.commonprefix(["/home/swen/spam", "/home/swen/eggs"]),
            "/home/swen/"
        )
        XCTAssertEqual(
            NTPath.commonprefix(["/home/swen/spam", "/home/swen/spam"]),
            "/home/swen/spam"
        )
        XCTAssertEqual(
            NTPath.commonprefix(["home:swenson:spam", "home:swen:spam"]),
            "home:swen"
        )
        XCTAssertEqual(
            NTPath.commonprefix([":home:swen:spam", ":home:swen:eggs"]),
            ":home:swen:"
        )
        XCTAssertEqual(
            NTPath.commonprefix([":home:swen:spam", ":home:swen:spam"]),
            ":home:swen:spam"
        )
    }

    static var allTests = [
        ("testIsabs", testIsabs),
        ("testJoin", testJoin),
        ("testSplit", testSplit),
        ("testSplitext", testSplitext),
        ("testSplitdrive", testSplitdrive),
        ("testBasename", testBasename),
        ("testDirname", testDirname),
        ("testNormpath", testNormpath),
        ("testRealpath", testRealpath),
        ("testRealpathBasic", testRealpathBasic),
        ("testCommonpath", testCommonpath),
        ("testCommonprefix", testCommonprefix),
    ]
}
