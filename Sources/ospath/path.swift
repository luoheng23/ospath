import Foundation

public class Path: PathObject {

    public var path: String
    public lazy var cls = type(of: self)

    public required init(_ path: String = "") {
        self.path = path
    }

    public static let curdir = "."
    public static let pardir = ".."
    public static let extsep = "."
    public static let tilde = "~"

    static let fileManager = FileManager.default

    class var sep: String {
        return "/"  // posix path
    }

    class var pathsep: String {
        return ":"
    }

    class var defpath: String {
        return "/bin:/usr/bin"
    }

    class var altsep: String? {
        return nil
    }

    class var devnull: String {
        return "/dev/null"
    }

    // nothing to do with posixpath
    public class func normcase<T: PathLike>(_ path: T) -> T {
        return path
    }

    // check if path is absolute
    public class func isabs<T: PathLike>(_ path: T) -> Bool {
        return path.path.hasPrefix(String(sep))
    }

    // join pathnames
    public class func join<T: PathLike>(_ basePath: T, _ toJoinedPaths: [T])
        -> T
    {
        var path = basePath.path
        for p in toJoinedPaths {
            let p = p.path
            if isabs(p) {
                // the path is an absolute path
                path = p
            }
            else if path == "" || path.hasSuffix(sep) {
                path += p
            }
            else {
                path += sep + p
            }
        }
        return T.init(path)
    }

    public class func join<T: PathLike>(_ basePath: T, _ toJoinedPaths: T...)
        -> T
    {
        return join(basePath, toJoinedPaths)
    }

    // split a path in head (everything up to the last '/') and tail (the rest)
    // if head is like usr////, remove tailed '/'
    public class func split<T: PathLike>(_ path: T) -> (head: T, tail: T) {
        var lastIndex: String.Index
        let pathStr = path.path
        if let pos = pathStr.lastIndex(where: { $0 == sep.first }) {
            lastIndex = pathStr.index(after: pos)
        }
        else {
            lastIndex = pathStr.startIndex
        }

        var (head, tail) = (pathStr[..<lastIndex], pathStr[lastIndex...])
        if !head.allSatisfy({ $0 == sep.first }) {
            // remove tailed '/'
            head.rstrip([sep.first!])
        }
        return (T.init(String(head)), T.init(String(tail)))
    }

    public class func basename<T: PathLike>(_ path: T) -> T {
        return split(path).tail
    }

    public class func dirname<T: PathLike>(_ path: T) -> T {
        return split(path).head
    }

    // nothing to do with posixpath
    public class func splitdrive<T: PathLike>(_ path: T) -> (head: T, tail: T) {
        return (type(of: path).init(""), path)
    }

    public class func normpath<T: PathLike>(_ path: T) -> T {
        let pathStr = path.path
        guard !pathStr.isEmpty else { return T.init(curdir) }

        var slashes = 0
        if pathStr.hasPrefix(sep) {
            slashes += 1
        }
        if slashes == 1 && pathStr.hasPrefix(sep + sep)
            && !pathStr.hasPrefix(sep + sep + sep)
        {
            slashes += 1
        }
        var comps = pathStr.split(separator: sep.first!)
        var newComps = [Substring]()
        for comp in comps {
            if comp == "" || comp == curdir {
                continue
            }
            if (comp != pardir || slashes == 0 && newComps.isEmpty)
                || (!newComps.isEmpty && newComps.last! == pardir)
            {
                newComps.append(comp)
            }
            else if !newComps.isEmpty {
                newComps.removeLast()
            }
        }
        comps = newComps
        var newPath = comps.joined(separator: sep)
        newPath = String(repeating: sep, count: slashes) + newPath
        guard !newPath.isEmpty else { return T.init(curdir) }
        return T.init(newPath)
    }

    public class func commonpath<T: PathLike>(_ paths: [T]) -> T {
        guard
            !paths.isEmpty
                && (paths.allSatisfy({ $0.path.hasPrefix(sep) })
                    || paths.allSatisfy({ !$0.path.hasPrefix(sep) }))
        else { return T.init("") }
        var splitPaths = paths.map { $0.path.split(separator: sep.first!) }
        splitPaths = splitPaths.map {
            $0.filter { $0.path != "" && $0.path != curdir }
        }
        let (s1, s2) = splitPaths.minmax()!
        let pre = paths[0].path.hasPrefix(sep) ? sep : ""
        for i in 0..<s1.count {
            if s1[i] != s2[i] {
                let common = s1[..<i]
                return T.init(pre + common.joined(separator: sep))
            }
        }
        let common = s1
        return T.init(pre + common.joined(separator: sep))
    }

    public class func commonpath<T: PathLike>(_ paths: T...) -> T {
        return commonpath(paths)
    }

    public class func splitext<T: PathLike>(_ path: T) -> (head: T, tail: T) {
        return _splitext(
            path: path,
            sep: sep,
            altsep: altsep,
            extsep: extsep
        )
    }

    public class func commonprefix<T: PathLike>(_ paths: [T]) -> T {
        guard !paths.isEmpty else { return T.init("") }

        let (minP, maxP) = (paths.map { $0.path }).minmax()!

        var idxMin = minP.startIndex
        var idxMax = maxP.startIndex
        while idxMin != minP.endIndex {
            if minP[idxMin] != maxP[idxMax] {
                return T.init(String(minP[..<idxMin]))
            }
            idxMin = minP.index(after: idxMin)
            idxMax = maxP.index(after: idxMax)
        }
        return T.init(minP)
    }

    public class func commonprefix<T: PathLike>(_ paths: T...) -> T {
        return commonprefix(paths)
    }

    public class func abspath<T: PathLike>(_ path: T) -> T {
        var p = path.path
        if !isabs(path.path) {
            let cwd = OS.getcwd()
            p = join(cwd, path.path)
        }
        return T.init(normpath(p))
    }

    public class func realpath<T: PathLike>(_ path: T) -> T {
        var seen: [String: String] = [:]
        let (path, _) = _joinrealpath(T.init(""), path, &seen)
        return abspath(path)
    }
}

extension Path {

    public class func expanduser<T: PathLike>(_ path: T) -> T {
        let pathStr = path.path
        guard pathStr.hasPrefix(tilde) else { return path }

        let idxAfterTilde = pathStr.index(after: pathStr.startIndex)
        let idx =
            pathStr.firstIndex(where: { $0 == sep.first }) ?? pathStr.endIndex
        // ~ and ~user
        let user = String(pathStr[idxAfterTilde..<idx])

        guard var userhome = OS.home(user) else { return path }
        // remove tailed '/'
        userhome.rstrip([sep.first!])
        userhome += pathStr[idx...]
        return T.init(userhome == "" ? "/" : userhome)
    }
}

extension Path {

    // Test whether a path is a symbolic link
    public class func islink<T: PathLike>(_ path: T) -> Bool {
        return (try? OS.lstat(path))?.islink ?? false
    }

    // Test whether a path exists. Returns True for broken symbolic links
    public class func lexists<T: PathLike>(_ path: T) -> Bool {
        return islink(path) || exists(path)
    }

    // Test whether a path exists. Returns False for broken symbolic links
    public class func exists<T: PathLike>(_ path: T) -> Bool {
        return (try? OS.stat(path))?.exist ?? false
    }

    // This follows symbolic links, so both islink() and isfile() can be true
    // for the same path on systems that support symlinks
    public class func isfile<T: PathLike>(_ path: T) -> Bool {
        return (try? OS.stat(path))?.isfile ?? false

    }

    // This follows symbolic links, so both islink() and isdir() can be true
    // for the same path on systems that support symlinks
    public class func isdir<T: PathLike>(_ path: T) -> Bool {
        return (try? OS.stat(path))?.isdir ?? false
    }

    public class func ismount<T: PathLike>(_ path: T) -> Bool {
        // s1 must not be link
        if islink(path) {
            return false
        }
        if let s1 = try? OS.lstat(path.path) {
            let parent = realpath(join(path.path, pardir))
            if let s2 = try? OS.lstat(parent) {
                return s1 == s2
            }
        }
        return false
    }

    public class func getsize<T: PathLike>(_ filename: T) -> Int? {
        return (try? OS.stat(filename))?.st_size
    }

    public class func getmtime<T: PathLike>(_ filename: T) -> Double? {
        return (try? OS.stat(filename))?.st_mtime
    }

    public class func getctime<T: PathLike>(_ filename: T) -> Double? {
        return (try? OS.stat(filename))?.st_ctime
    }

    public class func getatime<T: PathLike>(_ filename: T) -> Double? {
        return (try? OS.stat(filename))?.st_atime
    }

    public class func isReadable<T: PathLike>(_ filename: T) -> Bool {
        return Path.fileManager.isReadableFile(atPath: filename.path)
    }

    public class func isWritable<T: PathLike>(_ filename: T) -> Bool {
        return Path.fileManager.isWritableFile(atPath: filename.path)
    }

    public class func isExecutable<T: PathLike>(_ filename: T) -> Bool {
        return Path.fileManager.isExecutableFile(atPath: filename.path)
    }

    public class func isDeletable<T: PathLike>(_ filename: T) -> Bool {
        return Path.fileManager.isDeletableFile(atPath: filename.path)
    }

    public class func samefile<T: PathLike>(_ file1: T, _ file2: T) -> Bool {
        if let stat1 = try? OS.stat(file1), let stat2 = try? OS.stat(file2) {
            return stat1 == stat2
        }
        return false
    }
}

extension Path {

    static func _joinrealpath<T: PathLike>(
        _ path: T,
        _ rest: T,
        _ seen: inout [String: String]
    ) -> (
        T, Bool
    ) {
        var newPath = path.path
        var r = rest.path
        if isabs(rest) {
            r = String(r[r.index(after: r.startIndex)...])
            newPath = sep
        }

        while !r.isEmpty {
            let idx = r.firstIndex(where: { $0 == sep.first }) ?? r.endIndex
            var name = String(r[..<idx])
            if idx == r.endIndex {
                r = ""
            }
            else {
                r = String(r[r.index(after: idx)...])
            }

            if name == "" || name == curdir {
                continue
            }

            if name == pardir {
                if !newPath.isEmpty {
                    (newPath, name) = split(newPath)
                    if name == pardir {
                        newPath = join(newPath, pardir, pardir)
                    }
                }
                else {
                    newPath = pardir
                }
                continue
            }

            let p = join(newPath, name)
            if !islink(p) {
                newPath = p
                continue
            }

            if let v = seen[p] {
                newPath = v
                return (T.init(join(newPath, r)), false)
            }

            seen.removeValue(forKey: p)
            var ok: Bool
            (newPath, ok) = _joinrealpath(newPath, OS.readlink(p), &seen)
            if !ok {
                return (T.init(join(newPath, rest.path)), false)
            }

            seen[p] = newPath
        }
        return (T.init(newPath), true)
    }

    // if given string is not found, return startIndex
    // split a path in root and extension
    // The extension is everything starting at the last dot in the last
    // pathname component; the root is everything before that.
    // It is always true that root + ext == p.
    static func _splitext<T: PathLike>(
        path: T,
        sep: String,
        altsep: String?,
        extsep: String
    ) -> (
        T, T
    ) {
        var sepIndex: String.Index
        var sepIndexValid = true
        let pathStr = path.path
        if let pos = pathStr.lastIndex(where: { $0 == sep.first }) {
            sepIndex = pos
        }
        else {
            sepIndex = pathStr.startIndex
            sepIndexValid = false
        }
        if let alt = altsep {
            if let pos = pathStr[sepIndex...].lastIndex(where: {
                $0 == alt.first
            }) {
                sepIndex = pos
                sepIndexValid = true
            }
        }

        if let pos = pathStr[sepIndex...].lastIndex(where: {
            $0 == extsep.first
        }) {
            // skip all leading dots
            var filenameIndex =
                sepIndexValid
                ? pathStr.index(after: sepIndex) : pathStr.startIndex
            while filenameIndex != pos {
                if pathStr[filenameIndex] != extsep.first {
                    return (
                        T.init(String(pathStr[..<pos])),
                        T.init(String(pathStr[pos...]))
                    )
                }
                filenameIndex = pathStr.index(after: filenameIndex)
            }
        }
        return (path, T.init(""))
    }
}

extension Path {

    public var normcase: Path { return cls.init(cls.normcase(path)) }
    public var split: (head: Path, tail: Path) {
        let (head, tail) = cls.split(path)
        return (cls.init(head), cls.init(tail))
    }
    public var basename: Path { return split.tail }
    public var dirname: Path { return split.head }
    public var splitdrive: (head: Path, tail: Path) {
        let (head, tail) = cls.splitdrive(path)
        return (cls.init(head), cls.init(tail))
    }
    public var normpath: Path { return cls.init(cls.normpath(path)) }
    public var splitext: (head: Path, tail: Path) {
        let (head, tail) = cls.splitext(path)
        return (cls.init(head), cls.init(tail))
    }
    public var abspath: Path { return cls.init(cls.abspath(path)) }
    public var realpath: Path { return cls.init(cls.realpath(path)) }
    public var expanduser: Path { return cls.init(cls.expanduser(path)) }

    public var isabs: Bool { return cls.isabs(path) }
    // file operation
    public var islink: Bool { return cls.islink(path) }
    public var lexists: Bool { return cls.lexists(path) }
    public var exists: Bool { return cls.exists(path) }

    public var isfile: Bool { return cls.isfile(path) }
    public var isdir: Bool { return cls.isdir(path) }
    public var ismount: Bool { return cls.ismount(path) }

    public var size: Int? { return cls.getsize(path) }
    public var mtime: Double? { return cls.getmtime(path) }
    public var ctime: Double? { return cls.getctime(path) }
    public var atime: Double? { return cls.getatime(path) }

    public var isReadable: Bool { return cls.isReadable(path) }
    public var isWritable: Bool { return cls.isWritable(path) }
    public var isExecutable: Bool { return cls.isExecutable(path) }
    public var isDeletable: Bool { return cls.isDeletable(path) }

}

extension Path {

    public func join<T: PathLike>(_ toJoinedPaths: [T]) -> Path {
        let newPath = cls.join(T.init(path), toJoinedPaths)
        // return a new object
        return cls.init(newPath.path)
    }

    public func join<T: PathLike>(_ toJoinedPaths: T...) -> Path {
        return join(toJoinedPaths)
    }

    public func commonpath<T: PathLike>(_ paths: [T]) -> Path {
        return cls.init(
            cls.commonpath(cls.commonpath(paths), T.init(path)).path
        )
    }

    public func commonpath<T: PathLike>(_ paths: T...) -> Path {
        return commonpath(paths)
    }

    public func commonprefix<T: PathLike>(_ paths: [T]) -> Path {
        return cls.init(
            cls.commonprefix(cls.commonprefix(paths), T.init(path)).path
        )
    }

    public func commonprefix<T: PathLike>(_ paths: T...) -> Path {
        return commonprefix(paths)
    }

    public func samefile<T: PathLike>(_ path: T) -> Bool {
        return cls.samefile(self.path, path.path)
    }
}

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        // make sure PosixPath doesn't equal to NTPath
        return type(of: lhs) == type(of: rhs) && lhs.path == rhs.path
    }
}

extension Path: Comparable {
    public static func < (lhs: Path, rhs: Path) -> Bool {
        return lhs.path < rhs.path
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        return "\(String(describing: self))(\"\(path)\")"
    }
}
