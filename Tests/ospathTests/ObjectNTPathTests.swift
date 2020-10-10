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
        XCTAssert(NTPath("c:\\foo\\ba").split == (NTPath("c:\\foo"), NTPath("ba")))
        XCTAssert(
            NTPath("\\\\conky\\mountpoint\\foo\\ba").split == (
                NTPath("\\\\conky\\mountpoint\\foo"), NTPath("ba")
            )
        )

        XCTAssert(NTPath("c:\\").split == (NTPath("c:\\"), NTPath("")))
        XCTAssert(
            NTPath("\\\\conky\\mountpoint\\").split == (
                NTPath("\\\\conky\\mountpoint\\"), NTPath("")
            )
        )

        XCTAssert(NTPath("c:/").split == (NTPath("c:/"), NTPath("")))
        XCTAssert(
            NTPath("//conky/mountpoint/").split == (NTPath("//conky/mountpoint/"), NTPath(""))
        )
    }

    func testSplitext() {
        XCTAssert(NTPath("foo.ext").splitext == (NTPath("foo"), NTPath(".ext")))
        XCTAssert(NTPath("/foo/foo.ext").splitext == (NTPath("/foo/foo"), NTPath(".ext")))
        XCTAssert(NTPath(".ext").splitext == (NTPath(".ext"), NTPath("")))
        XCTAssert(NTPath("\\foo.ext\\foo").splitext == (NTPath("\\foo.ext\\foo"), NTPath("")))
        XCTAssert(NTPath("foo.ext\\").splitext == (NTPath("foo.ext\\"), NTPath("")))
        XCTAssert(NTPath("").splitext == (NTPath(""), NTPath("")))
        XCTAssert(NTPath("foo.bar.ext").splitext == (NTPath("foo.bar"), NTPath(".ext")))
        XCTAssert(NTPath("xx/foo.bar.ext").splitext == (NTPath("xx/foo.bar"), NTPath(".ext")))
        XCTAssert(NTPath("xx\\foo.bar.ext").splitext == (NTPath("xx\\foo.bar"), NTPath(".ext")))
        XCTAssert(NTPath("c:a/b\\c.d").splitext == (NTPath("c:a/b\\c"), NTPath(".d")))
    }

    func testSplitdrive() {
        XCTAssert(NTPath("c:\\foo\\ba").splitdrive == (NTPath("c:"), NTPath("\\foo\\ba")))
        XCTAssert(NTPath("c:/foo/ba").splitdrive == (NTPath("c:"), NTPath("/foo/ba")))
        XCTAssert(
            NTPath("\\\\conky\\mountpoint\\foo\\ba").splitdrive == (
                NTPath("\\\\conky\\mountpoint"), NTPath("\\foo\\ba")
            )
        )
        XCTAssert(
            NTPath("//conky/mountpoint/foo/ba").splitdrive == (
                NTPath("//conky/mountpoint"), NTPath("/foo/ba")
            )
        )
        XCTAssert(
            NTPath("\\\\\\conky\\mountpoint\\foo\\ba").splitdrive == (
                NTPath(""), NTPath("\\\\\\conky\\mountpoint\\foo\\ba")
            )
        )
        XCTAssert(
            NTPath("///conky/mountpoint/foo/ba").splitdrive == (
                NTPath(""), NTPath("///conky/mountpoint/foo/ba")
            )
        )
        XCTAssert(
            NTPath("\\\\conky\\\\mountpoint\\foo\\ba").splitdrive == (
                NTPath(""), NTPath("\\\\conky\\\\mountpoint\\foo\\ba")
            )
        )
        XCTAssert(
            NTPath("//conky//mountpoint/foo/ba").splitdrive == (
                NTPath(""), NTPath("//conky//mountpoint/foo/ba")
            )
        )
    }

    func testBasename() {
        XCTAssertEqual(NTPath("/foo/ba").basename, NTPath("ba"))
        XCTAssertEqual(NTPath("/").basename, NTPath(""))
        XCTAssertEqual(NTPath("foo").basename, NTPath("foo"))
        XCTAssertEqual(NTPath("////foo").basename, NTPath("foo"))
        XCTAssertEqual(NTPath("//foo//ba").basename, NTPath("ba"))
    }

    func testDirname() {
        XCTAssertEqual(NTPath("/foo/ba").dirname, NTPath("/foo"))
        XCTAssertEqual(NTPath("/").dirname, NTPath("/"))
        XCTAssertEqual(NTPath("foo").dirname, NTPath(""))
        XCTAssertEqual(NTPath("////foo").dirname, NTPath("////"))
        XCTAssertEqual(NTPath("//foo//ba").dirname, NTPath("//foo"))
    }

    func testNormpath() {
        XCTAssertEqual(NTPath("A//////././//.//B").normpath, NTPath("A\\B"))
        XCTAssertEqual(NTPath("A/./B").normpath, NTPath("A\\B"))
        XCTAssertEqual(NTPath("A/foo/../B").normpath, NTPath("A\\B"))
        XCTAssertEqual(NTPath("C:A//B").normpath, NTPath("C:A\\B"))
        XCTAssertEqual(NTPath("D:A/./B").normpath, NTPath("D:A\\B"))
        XCTAssertEqual(NTPath("e:A/foo/../B").normpath, NTPath("e:A\\B"))

        XCTAssertEqual(NTPath("C:///A//B").normpath, NTPath("C:\\A\\B"))
        XCTAssertEqual(NTPath("D:///A/./B").normpath, NTPath("D:\\A\\B"))
        XCTAssertEqual(NTPath("e:///A/foo/../B").normpath, NTPath("e:\\A\\B"))

        XCTAssertEqual(NTPath("..").normpath, NTPath(".."))
        XCTAssertEqual(NTPath(".").normpath, NTPath("."))
        XCTAssertEqual(NTPath("").normpath, NTPath("."))
        XCTAssertEqual(NTPath("/").normpath, NTPath("\\"))
        XCTAssertEqual(NTPath("c:/").normpath, NTPath("c:\\"))
        XCTAssertEqual(NTPath("/../.././..").normpath, NTPath("\\"))
        XCTAssertEqual(NTPath("c:/../../..").normpath, NTPath("c:\\"))
        XCTAssertEqual(NTPath("../.././..").normpath, NTPath("..\\..\\.."))
        XCTAssertEqual(NTPath("K:../.././..").normpath, NTPath("K:..\\..\\.."))
        XCTAssertEqual(NTPath("C:////a/b").normpath, NTPath("C:\\a\\b"))
        XCTAssertEqual(
            NTPath("//machine/share//a/b").normpath,
            NTPath("\\\\machine\\share\\a\\b")
        )

        XCTAssertEqual(NTPath("\\\\.\\NUL").normpath, NTPath("\\\\.\\NUL"))

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
    ]
}
