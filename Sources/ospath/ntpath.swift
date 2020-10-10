import Foundation

public class NTPath: Path {

    private static var seps: Set<Character> = ["\\", "/"]
    private static var specialPrefixes = ["\\\\?\\", "\\\\.\\"]

    override public class var sep: String {
        return "\\"  // nt path
    }

    override public class var pathsep: String {
        return ";"
    }

    override public class var defpath: String {
        return ".;C:\\bin"
    }

    override public class var altsep: String? {
        return "/"
    }

    override public class var devnull: String {
        return "nul"
    }

    override public class func normcase<T: PathLike>(_ path: T) -> T {
        return type(of: path).init(
            path.path.replacingOccurrences(of: altsep!, with: sep)
        )
    }

    // check if path is absolute
    override public class func isabs<T: PathLike>(_ path: T) -> Bool {
        guard !normcase(path).path.hasPrefix(specialPrefixes[0]) else {
            return true
        }
        guard let c = splitdrive(path).tail.path.first, seps.contains(c) else {
            return false
        }
        return true
    }

    // join pathnames
    override public class func join<T: PathLike>(
        _ basePath: T,
        _ toJoinedPaths: [T]
    ) -> T {
        var (drive, p) = splitdrive(basePath)
        var path = p.path
        for p in toJoinedPaths {
            let (pDrive, pPath) = splitdrive(p)
            // absolute path
            if let c = pPath.path.first, seps.contains(c) {
                if drive.path.isEmpty || !pDrive.path.isEmpty {
                    drive = pDrive
                }
                path = pPath.path
                continue
            }
            else if !pDrive.path.isEmpty && pDrive.path != drive.path {
                if pDrive.path.lowercased() != drive.path.lowercased() {
                    drive = pDrive
                    path = pPath.path
                    continue
                }
                drive = pDrive
            }
            if let c = path.last, !seps.contains(c) {
                path += sep
            }
            path += pPath.path
        }
        if let c = path.first, let d = drive.path.last,
            !seps.contains(c) && d != ":"
        {
            return T.init(drive.path + sep + path)
        }
        return T.init(drive.path + path)
    }

    // split a path in head (everything up to the last '/') and tail (the rest)
    // if head is like usr////, remove tailed '/'
    override public class func split<T: PathLike>(_ path: T) -> (
        head: T, tail: T
    ) {
        let (d, p) = splitdrive(path)
        let pathStr = p.path
        var i = pathStr.endIndex
        while i != pathStr.startIndex
            && !seps.contains(pathStr[pathStr.index(before: i)])
        {
            i = pathStr.index(before: i)
        }
        var (head, tail) = (pathStr[..<i], pathStr[i...])

        if !head.allSatisfy({ seps.contains($0) }) {
            head.rstrip(seps)
        }
        return (T.init(String(d.path + head)), T.init(String(tail)))
    }

    override public class func splitdrive<T: PathLike>(_ path: T) -> (
        head: T, tail: T
    ) {
        guard path.path.count >= 2 else { return (T.init(""), path) }

        let normp = normcase(path).path
        if normp.hasPrefix(sep + sep) && !normp.hasPrefix(sep + sep + sep) {
            if let index = normp[normp.index(normp.startIndex, offsetBy: 2)...]
                .firstIndex(where: {
                    $0 == sep.first
                })
            {
                if let index2 = normp[normp.index(after: index)...].firstIndex(
                    where: { $0 == sep.first })
                {
                    if index2 == normp.index(after: index) {
                        return (T.init(""), path)
                    }
                    return (
                        T.init(String(path.path[..<index2])),
                        T.init(String(path.path[index2...]))
                    )
                }
                else {
                    return (path, T.init(""))
                }
            }
            else {
                return (T.init(""), path)
            }
        }

        if normp[normp.index(after: normp.startIndex)] == ":" {
            let index = normp.index(normp.startIndex, offsetBy: 2)
            return (
                T.init(String(path.path[..<index])),
                T.init(String(path.path[index...]))
            )
        }
        return (T.init(""), path)
    }

    override public class func normpath<T: PathLike>(_ path: T) -> T {
        let T = type(of: path)
        let pathStr = path.path
        guard !pathStr.isEmpty else { return T.init(curdir) }
        guard
            !pathStr.hasPrefix(specialPrefixes[0])
                && !pathStr.hasPrefix(specialPrefixes[1])
        else {
            return path
        }

        var (drive, p) = splitdrive(normcase(pathStr))

        if p.hasPrefix(sep) {
            drive += sep
            p.lstrip(seps)
        }

        var comps = p.split(separator: sep.first!)
        var i = 0
        while i < comps.count {
            if comps[i] == "" || comps[i] == curdir {
                comps.remove(at: i)
            }
            else if comps[i] == pardir {
                if i > 0 && comps[i - 1] != pardir {
                    comps.removeSubrange((i - 1)...i)
                    i -= 1
                }
                else if i == 0 && drive.last == sep.first! {
                    comps.remove(at: i)
                }
                else {
                    i += 1
                }
            }
            else {
                i += 1
            }
        }
        if drive.isEmpty && comps.isEmpty {
            comps.append(curdir[...])
        }

        return T.init(drive + comps.joined(separator: sep))
    }

    override public class func commonpath<T: PathLike>(_ paths: [T]) -> T {
        guard !paths.isEmpty else { return T.init("") }
        guard paths.count != 1 else { return paths[0] }

        let driveSplit = paths.map {
            splitdrive(normpath($0.path).lowercased())
        }
        var splitPaths = driveSplit.map { $0.1.split(separator: sep.first!) }

        guard
            (driveSplit.allSatisfy({ $0.1.hasPrefix(sep) })
                || driveSplit.allSatisfy({ !$0.1.hasPrefix(sep) }))
                && driveSplit.allSatisfy({ $0.0 == driveSplit[0].0 })
        else { return T.init("") }

        let (drive, pathStr) = splitdrive(normcase(paths[0].path))
        var common = pathStr.split(separator: sep.first!)
        common = common.filter { $0 != curdir }
        splitPaths = splitPaths.map { $0.filter { $0 != curdir } }

        let (s1, s2) = splitPaths.minmax()!
        let pre = pathStr.hasPrefix(sep) ? drive + sep : drive
        for i in 0..<s1.count {
            if s1[i] != s2[i] {
                return T.init(pre + common[..<i].joined(separator: sep))
            }
        }
        return T.init(pre + common.joined(separator: sep))
    }
}
