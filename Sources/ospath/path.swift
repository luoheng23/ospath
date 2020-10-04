import Foundation

public class BasePath {
    static let curdir = "."
    static let pardir = ".."
    static let extsep = "."
    static let tilde = "~"

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
    public class func normcase(_ path: String) -> String {
        return path
    }

    // check if path is absolute
    public class func isabs(_ path: String) -> Bool {
        return path.hasPrefix(String(sep))
    }

    // join pathnames
    public class func join(_ basePath: String, _ toJoinedPaths: String...)
        -> String
    {
        var path = basePath
        for p in toJoinedPaths {
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
        return path
    }

    // split a path in head (everything up to the last '/') and tail (the rest)
    // if head is like usr////, remove tailed '/'
    public class func split(_ path: String) -> (head: String, tail: String) {
        var lastIndex: String.Index
        if let pos = path.lastIndex(where: { $0 == sep.first }) {
            lastIndex = path.index(after: pos)
        }
        else {
            lastIndex = path.startIndex
        }

        var (head, tail) = (path[..<lastIndex], path[lastIndex...])
        if !head.allSatisfy({ $0 == sep.first }) {
            // remove tailed '/'
            head.rstrip([sep.first!])
        }
        return (String(head), String(tail))
    }

    // nothing to do with posixpath
    public class func splitdrive(_ path: String) -> (head: String, tail: String)
    {
        return ("", path)
    }

    public class func normpath(_ path: String) -> String {
        guard !path.isEmpty else { return curdir }

        var slashes = 0
        if path.hasPrefix(sep) {
            slashes += 1
        }
        if slashes == 1 && path.hasPrefix(sep + sep)
            && !path.hasPrefix(sep + sep + sep)
        {
            slashes += 1
        }
        var comps = path.split(separator: sep.first!)
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
        guard !newPath.isEmpty else { return curdir }
        return newPath
    }

    public class func commonpath(_ paths: [String]) -> String {
        guard
            !paths.isEmpty
                && (paths.allSatisfy({ $0.hasPrefix(sep) })
                    || paths.allSatisfy({ !$0.hasPrefix(sep) }))
        else { return "" }
        var splitPaths = paths.map { $0.split(separator: sep.first!) }
        splitPaths = splitPaths.map { $0.filter { $0 != "" && $0 != curdir } }
        var s1 = splitPaths[0]
        var s2 = splitPaths[0]
        for c in splitPaths {
            if bigThan(c, s2) {
                s2 = c
            }
            else if bigThan(s1, c) {
                s1 = c
            }
        }
        let pre = paths[0].hasPrefix(sep) ? sep : ""
        for i in 0..<s1.count {
            if s1[i] != s2[i] {
                let common = s1[..<i]
                return pre + common.joined(separator: sep)
            }
        }
        let common = s1
        return pre + common.joined(separator: sep)
    }

}

extension BasePath {
    public class func splitext(_ path: String) -> (head: String, tail: String) {
        return Path.splitext(
            path: path,
            sep: sep,
            altsep: altsep,
            extsep: extsep
        )
    }

    public class func commonprefix(_ paths: [String]) -> String {
        guard !paths.isEmpty else { return "" }

        let minP = paths.min()!
        let maxP = paths.max()!

        var idxMin = minP.startIndex
        var idxMax = maxP.startIndex
        while idxMin != minP.endIndex {
            if minP[idxMin] != maxP[idxMax] {
                return String(minP[..<idxMin])
            }
            idxMin = minP.index(after: idxMin)
            idxMax = maxP.index(after: idxMax)
        }
        return minP
    }
}

extension BasePath {

    public class func basename(_ path: String) -> String {
        return split(path).tail
    }

    public class func dirname(_ path: String) -> String {
        return split(path).head
    }

    public class func islink(_ path: String) -> Bool {
        do {
            let attrs = try Path.fileManager.attributesOfItem(atPath: path)
            if let attr = attrs[.type] {
                return (attr as! FileAttributeType) == .typeSymbolicLink
            }
            return false
        }
        catch {
            return false
        }
    }

    public class func lexists(_ path: String) -> Bool {
        do {
            let _ = try Path.fileManager.destinationOfSymbolicLink(atPath: path)
            return true
        }
        catch {
            return false
        }
    }

    public class func exists(_ path: String) -> Bool {
        return Path.fileManager.fileExists(atPath: path)
    }

    public class func isfile(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        if Path.fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            return !isDir.boolValue
        }
        return false
    }

    public class func isdir(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        if Path.fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }

    public class func ismount(_ path: String) -> Bool {
        var s1: StatResult
        var s2: StatResult
        do {
            s1 = try OS.stat(path)
            if islink(path) {
                return false
            }
        }
        catch {
            return false
        }

        let parent = realpath(join(path, pardir))
        do {
            s2 = try OS.stat(parent)
        }
        catch {
            return false
        }
        return samestat(s1, s2)
    }

    public class func getsize(_ filename: String) -> Int {
        do {
            let stat = try OS.stat(filename)
            return stat.st_size
        }
        catch {
            return -1
        }
    }

    public class func getmtime(_ filename: String) -> Double {
        do {
            let stat = try OS.stat(filename)
            return stat.st_mtime
        }
        catch {
            return -1
        }
    }

    public class func getctime(_ filename: String) -> Double {
        do {
            let stat = try OS.stat(filename)
            return stat.st_ctime
        }
        catch {
            return -1
        }
    }

    public class func getatime(_ filename: String) -> Double {
        do {
            let stat = try OS.stat(filename)
            return stat.st_atime
        }
        catch {
            return -1
        }
    }

    public class func isReadable(_ filename: String) -> Bool {
        return Path.fileManager.isReadableFile(atPath: filename)
    }

    public class func isWritable(_ filename: String) -> Bool {
        return Path.fileManager.isWritableFile(atPath: filename)
    }

    public class func isExecutable(_ filename: String) -> Bool {
        return Path.fileManager.isExecutableFile(atPath: filename)
    }

    public class func isDeletable(_ filename: String) -> Bool {
        return Path.fileManager.isDeletableFile(atPath: filename)
    }

    class func samestat(_ stat1: StatResult, _ stat2: StatResult) -> Bool {
        return stat1.st_ino == stat2.st_ino && stat1.st_dev == stat2.st_dev
    }

    public class func samefile(_ file1: String, _ file2: String) -> Bool {
        do {
            let stat1 = try OS.stat(file1)
            let stat2 = try OS.stat(file2)
            return samestat(stat1, stat2)
        }
        catch {
            return false
        }
    }

    public class func expanduser(_ path: String) -> String {
        guard path.hasPrefix(tilde) else { return path }

        let idxAfterTilde = path.index(after: path.startIndex)
        let idx = path.firstIndex(where: { $0 == sep.first }) ?? path.endIndex
        // ~ and ~user
        let user = String(path[idxAfterTilde..<idx])

        guard var userhome = OS.home(user) else { return path }
        // remove tailed '/'
        userhome.rstrip([sep.first!])
        userhome += path[idx...]
        return userhome == "" ? "/" : userhome
    }
}

extension BasePath {
    static func bigThan(_ s1: [String.SubSequence], _ s2: [String.SubSequence])
        -> Bool
    {
        let length = min(s1.count, s2.count)
        for i in 0..<length {
            if s1[i] > s2[i] {
                return true
            }
            if s1[i] < s2[i] {
                return false
            }
        }
        return false
    }

    public class func abspath(_ path: String) -> String {
        var p = path
        if !isabs(path) {
            let cwd = OS.getcwd()
            p = join(cwd, path)
        }
        return normpath(p)
    }

    public class func realpath(_ filename: String) -> String {
        var seen: [String: String] = [:]
        let (path, _) = _joinrealpath("", filename, &seen)
        return abspath(path)
    }

    static func _joinrealpath(
        _ path: String,
        _ rest: String,
        _ seen: inout [String: String]
    ) -> (
        String, Bool
    ) {
        var newPath = path
        var r = rest
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
                return (join(newPath, r), false)
            }

            seen.removeValue(forKey: p)
            var ok: Bool
            (newPath, ok) = _joinrealpath(newPath, OS.readlink(p), &seen)
            if !ok {
                return (join(newPath, rest), false)
            }

            seen[p] = newPath
        }
        return (newPath, true)
    }
}
