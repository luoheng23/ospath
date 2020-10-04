import XCTest

@testable import ospath

final class NTPathTests: XCTestCase {

    func testIsabs() {
        XCTAssertEqual(NTPath.isabs("c:\\"), true)
        XCTAssertEqual(NTPath.isabs("\\\\conky\\mountpoint\\"), true)
        XCTAssertEqual(NTPath.isabs("\\foo"), true)
        XCTAssertEqual(NTPath.isabs("\\foo\\bar"), true)
    }

    func testJoin() {
        XCTAssertEqual(NTPath.join(""), "")
        XCTAssertEqual(NTPath.join("", "", ""), "")
        XCTAssertEqual(NTPath.join("a"), "a")
        XCTAssertEqual(NTPath.join("/a"), "/a")
        XCTAssertEqual(NTPath.join("\\a"), "\\a")
        XCTAssertEqual(NTPath.join("a:"), "a:")
        XCTAssertEqual(NTPath.join("a:", "\\b"), "a:\\b")
        XCTAssertEqual(NTPath.join("a", "\\b"), "\\b")
        XCTAssertEqual(NTPath.join("a", "b", "c"), "a\\b\\c")
        XCTAssertEqual(NTPath.join("a\\", "b", "c"), "a\\b\\c")
        XCTAssertEqual(NTPath.join("a", "b\\", "c"), "a\\b\\c")
        XCTAssertEqual(NTPath.join("a", "b", "\\c"), "\\c")
        XCTAssertEqual(NTPath.join("d:\\", "\\pleep"), "d:\\pleep")
        XCTAssertEqual(NTPath.join("d:\\", "a", "b"), "d:\\a\\b")

        XCTAssertEqual(NTPath.join("", "a"), "a")
        XCTAssertEqual(NTPath.join("", "", "", "", "a"), "a")
        XCTAssertEqual(NTPath.join("a", ""), "a\\")
        XCTAssertEqual(NTPath.join("a", "", "", "", ""), "a\\")
        XCTAssertEqual(NTPath.join("a\\", ""), "a\\")
        XCTAssertEqual(NTPath.join("a\\", "", "", "", ""), "a\\")
        XCTAssertEqual(NTPath.join("a/", ""), "a/")

        XCTAssertEqual(NTPath.join("a/b", "x/y"), "a/b\\x/y")
        XCTAssertEqual(NTPath.join("/a/b", "x/y"), "/a/b\\x/y")
        XCTAssertEqual(NTPath.join("/a/b/", "x/y"), "/a/b/x/y")
        XCTAssertEqual(NTPath.join("c:", "x/y"), "c:x/y")
        XCTAssertEqual(NTPath.join("c:a/b", "x/y"), "c:a/b\\x/y")
        XCTAssertEqual(NTPath.join("c:a/b/", "x/y"), "c:a/b/x/y")
        XCTAssertEqual(NTPath.join("c:/", "x/y"), "c:/x/y")
        XCTAssertEqual(NTPath.join("c:/a/b", "x/y"), "c:/a/b\\x/y")
        XCTAssertEqual(NTPath.join("c:/a/b/", "x/y"), "c:/a/b/x/y")
        XCTAssertEqual(
            NTPath.join("//computer/share", "x/y"),
            "//computer/share\\x/y"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share/", "x/y"),
            "//computer/share/x/y"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share/a/b", "x/y"),
            "//computer/share/a/b\\x/y"
        )

        XCTAssertEqual(NTPath.join("a/b", "/x/y"), "/x/y")
        XCTAssertEqual(NTPath.join("/a/b", "/x/y"), "/x/y")
        XCTAssertEqual(NTPath.join("c:", "/x/y"), "c:/x/y")
        XCTAssertEqual(NTPath.join("c:a/b", "/x/y"), "c:/x/y")
        XCTAssertEqual(NTPath.join("c:/", "/x/y"), "c:/x/y")
        XCTAssertEqual(NTPath.join("c:/a/b", "/x/y"), "c:/x/y")
        XCTAssertEqual(
            NTPath.join("//computer/share", "/x/y"),
            "//computer/share/x/y"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share/", "/x/y"),
            "//computer/share/x/y"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share/a", "/x/y"),
            "//computer/share/x/y"
        )

        XCTAssertEqual(NTPath.join("c:", "C:x/y"), "C:x/y")
        XCTAssertEqual(NTPath.join("c:a/b", "C:x/y"), "C:a/b\\x/y")
        XCTAssertEqual(NTPath.join("c:/", "C:x/y"), "C:/x/y")
        XCTAssertEqual(NTPath.join("c:/a/b", "C:x/y"), "C:/a/b\\x/y")

        for x in [
            "", "a/b", "/a/b", "c:", "c:a/b", "c:/", "c:/a/b",
            "//computer/share", "//computer/share/", "//computer/share/a/b",
        ] {
            for y in [
                "d:", "d:x/y", "d:/", "d:/x/y",
                "//machine/common", "//machine/common/", "//machine/common/x/y",
            ] {
                XCTAssertEqual(NTPath.join(x, y), y)

            }

        }

        XCTAssertEqual(
            NTPath.join("\\\\computer\\share\\", "a", "b"),
            "\\\\computer\\share\\a\\b"
        )
        XCTAssertEqual(
            NTPath.join("\\\\computer\\share", "a", "b"),
            "\\\\computer\\share\\a\\b"
        )
        XCTAssertEqual(
            NTPath.join("\\\\computer\\share", "a\\b"),
            "\\\\computer\\share\\a\\b"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share/", "a", "b"),
            "//computer/share/a\\b"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share", "a", "b"),
            "//computer/share\\a\\b"
        )
        XCTAssertEqual(
            NTPath.join("//computer/share", "a/b"),
            "//computer/share\\a/b"
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

    func testIslink() {
        let filename = "sdafsdfhdsufhisfu232u3fjdsjhfksfs"
        let newfile = filename + "1"
        let link = filename + "2"
        _ = try? OS.remove(newfile)
        _ = try? OS.remove(link)
        XCTAssertEqual(NTPath.islink(newfile), false)
        XCTAssertEqual(NTPath.lexists(link), false)
        XCTAssertEqual(NTPath.islink(newfile), false)

        if OS.open(newfile) {
            _ = try? OS.symlink(newfile, link)
            XCTAssertEqual(NTPath.islink(link), true)
            _ = try? OS.remove(newfile)
            XCTAssertEqual(NTPath.islink(link), true)
            XCTAssertEqual(NTPath.exists(link), false)
            XCTAssertEqual(NTPath.lexists(link), true)
            _ = try? OS.remove(link)
        }
    }

    func testIsfile() {
        XCTAssertTrue(NTPath.isfile("README.md"))
        XCTAssertFalse(NTPath.isfile("Sources"))
        XCTAssertFalse(NTPath.isfile("Source"))
    }

    func testIsdir() {
        XCTAssertFalse(NTPath.isdir("README.md"))
        XCTAssertFalse(NTPath.isdir("README.mds"))
        XCTAssertTrue(NTPath.isdir("Sources"))
    }

    func testIsmount() {
        XCTAssertTrue(NTPath.ismount("c:\\"))
        XCTAssertTrue(NTPath.ismount("C:\\"))
        XCTAssertTrue(NTPath.ismount("c:/"))
        XCTAssertTrue(NTPath.ismount("C:/"))
        XCTAssertTrue(NTPath.ismount("\\\\.\\c:\\"))
        XCTAssertTrue(NTPath.ismount("\\\\.\\C:\\"))
    }

    func testGetsize() {
        // if LICENSE changed, this test will fail
        let filename = "LICENSE"
        let size = 1064
        XCTAssertEqual(NTPath.getsize(filename), size)
    }

    func testExpanduser() {
        XCTAssertEqual(NTPath.expanduser("foo"), "foo")
        let env = ProcessInfo.processInfo.environment
        XCTAssertEqual(NTPath.expanduser("~"), env["HOME"] ?? "")
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
