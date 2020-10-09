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

    override public class func normcase(_ path: String) -> String {
        return path.replacingOccurrences(of: altsep!, with: sep)
    }

    // check if path is absolute
    override public class func isabs(_ path: String) -> Bool {
        guard !normcase(path).hasPrefix(specialPrefixes[0]) else { return true }
        guard let c = splitdrive(path).tail.first, seps.contains(c) else {
            return false
        }
        return true
    }

    // join pathnames
    override public class func join(
        _ basePath: String,
        _ toJoinedPaths: [String]
    ) -> String {
        var (drive, path) = splitdrive(basePath)
        for p in toJoinedPaths {
            let (pDrive, pPath) = splitdrive(p)
            // absolute path
            if let c = pPath.first, seps.contains(c) {
                if drive.isEmpty || !pDrive.isEmpty {
                    drive = pDrive
                }
                path = pPath
                continue
            }
            else if !pDrive.isEmpty && pDrive != drive {
                if pDrive.lowercased() != drive.lowercased() {
                    drive = pDrive
                    path = pPath
                    continue
                }
                drive = pDrive
            }
            if let c = path.last, !seps.contains(c) {
                path += sep
            }
            path += pPath
        }
        if let c = path.first, let d = drive.last, !seps.contains(c) && d != ":"
        {
            return drive + sep + path
        }
        return drive + path
    }

    // split a path in head (everything up to the last '/') and tail (the rest)
    // if head is like usr////, remove tailed '/'
    override public class func split(_ path: String) -> (
        head: String, tail: String
    ) {
        let (d, p) = splitdrive(path)
        var i = p.endIndex
        while i != p.startIndex && !seps.contains(p[p.index(before: i)]) {
            i = p.index(before: i)
        }
        var (head, tail) = (p[..<i], p[i...])

        if !head.allSatisfy({ seps.contains($0) }) {
            head.rstrip(seps)
        }
        return (String(d + head), String(tail))
    }

    override public class func splitdrive(_ path: String) -> (
        head: String, tail: String
    ) {
        guard path.count >= 2 else { return ("", path) }
        let normp = normcase(path)
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
                        return ("", path)
                    }
                    return (String(path[..<index2]), String(path[index2...]))
                }
                else {
                    return (path, "")
                }
            }
            else {
                return ("", path)
            }
        }

        if normp[normp.index(after: normp.startIndex)] == ":" {
            let index = normp.index(normp.startIndex, offsetBy: 2)
            return (String(path[..<index]), String(path[index...]))
        }
        return ("", path)
    }

    override public class func normpath(_ path: String) -> String {
        guard !path.isEmpty else { return curdir }
        guard
            !path.hasPrefix(specialPrefixes[0])
                && !path.hasPrefix(specialPrefixes[1])
        else {
            return path
        }

        var (drive, p) = splitdrive(normcase(path))

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

        return drive + comps.joined(separator: sep)
    }

    override public class func commonpath(_ paths: [String]) -> String {
        guard !paths.isEmpty else { return "" }
        guard paths.count != 1 else { return paths[0] }

        let driveSplit = paths.map { splitdrive(normpath($0).lowercased()) }
        var splitPaths = driveSplit.map { $0.1.split(separator: sep.first!) }

        guard
            (driveSplit.allSatisfy({ $0.1.hasPrefix(sep) })
                || driveSplit.allSatisfy({ !$0.1.hasPrefix(sep) }))
                && driveSplit.allSatisfy({ $0.0 == driveSplit[0].0 })
        else { return "" }

        let (drive, path) = splitdrive(normcase(paths[0]))
        var common = path.split(separator: sep.first!)
        common = common.filter { $0 != curdir }
        splitPaths = splitPaths.map { $0.filter { $0 != curdir } }

        let (s1, s2) = splitPaths.minmax()!
        let pre = path.hasPrefix(sep) ? drive + sep : drive
        for i in 0..<s1.count {
            if s1[i] != s2[i] {
                return pre + common[..<i].joined(separator: sep)
            }
        }
        return pre + common.joined(separator: sep)
    }
}
