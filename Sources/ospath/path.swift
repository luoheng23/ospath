import Foundation

public class Path {
    static let curdir = "."
    static let pardir = ".."
    static let extsep = "."
    static let tilde = "~"

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

    public class func basename(_ path: String) -> String {
        return split(path).tail
    }

    public class func dirname(_ path: String) -> String {
        return split(path).head
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
        let (s1, s2) = splitPaths.minmax()!
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

    public class func splitext(_ path: String) -> (head: String, tail: String) {
        return _splitext(
            path: path,
            sep: sep,
            altsep: altsep,
            extsep: extsep
        )
    }

    public class func commonprefix(_ paths: [String]) -> String {
        guard !paths.isEmpty else { return "" }

        let (minP, maxP) = paths.minmax()!

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
}

extension Path {
    
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

extension Path {

    // Test whether a path is a symbolic link
    public class func islink(_ path: String) -> Bool {
        return (try? OS.lstat(path))?.islink ?? false
    }

    // Test whether a path exists. Returns True for broken symbolic links
    public class func lexists(_ path: String) -> Bool {
        return islink(path) || exists(path)
    }

    // Test whether a path exists. Returns False for broken symbolic links
    public class func exists(_ path: String) -> Bool {
        return (try? OS.stat(path))?.exist ?? false
    }

    // This follows symbolic links, so both islink() and isfile() can be true
    // for the same path on systems that support symlinks
    public class func isfile(_ path: String) -> Bool {
        return (try? OS.stat(path))?.isfile ?? false

    }

    // This follows symbolic links, so both islink() and isdir() can be true
    // for the same path on systems that support symlinks
    public class func isdir(_ path: String) -> Bool {
        return (try? OS.stat(path))?.isdir ?? false
    }

    public class func ismount(_ path: String) -> Bool {
        // s1 must not be link
        if islink(path) {
            return false
        }
        if let s1 = try? OS.lstat(path) {
            let parent = realpath(join(path, pardir))
            if let s2 = try? OS.lstat(parent) {
                return s1 == s2
            }
        }
        return false
    }

    public class func getsize(_ filename: String) -> Int? {
        return (try? OS.stat(filename))?.st_size
    }

    public class func getmtime(_ filename: String) -> Double? {
        return (try? OS.stat(filename))?.st_mtime
    }

    public class func getctime(_ filename: String) -> Double? {
        return (try? OS.stat(filename))?.st_ctime
    }

    public class func getatime(_ filename: String) -> Double? {
        return (try? OS.stat(filename))?.st_atime
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

    public class func samefile(_ file1: String, _ file2: String) -> Bool {
        if let stat1 = try? OS.stat(file1), let stat2 = try? OS.stat(file2) {
            return stat1 == stat2
        }
        return false
    }
}

extension Path {

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

    // if given string is not found, return startIndex
    // split a path in root and extension
    // The extension is everything starting at the last dot in the last
    // pathname component; the root is everything before that.
    // It is always true that root + ext == p.
    static func _splitext(
        path: String,
        sep: String,
        altsep: String?,
        extsep: String
    ) -> (
        String, String
    ) {
        var sepIndex: String.Index
        var sepIndexValid = true
        if let pos = path.lastIndex(where: { $0 == sep.first }) {
            sepIndex = pos
        }
        else {
            sepIndex = path.startIndex
            sepIndexValid = false
        }
        if let alt = altsep {
            if let pos = path[sepIndex...].lastIndex(where: { $0 == alt.first })
            {
                sepIndex = pos
                sepIndexValid = true
            }
        }

        if let pos = path[sepIndex...].lastIndex(where: { $0 == extsep.first })
        {
            // skip all leading dots
            var filenameIndex =
                sepIndexValid ? path.index(after: sepIndex) : path.startIndex
            while filenameIndex != pos {
                if path[filenameIndex] != extsep.first {
                    return (String(path[..<pos]), String(path[pos...]))
                }
                filenameIndex = path.index(after: filenameIndex)
            }
        }
        return (path, "")
    }
}




extension String.SubSequence {
    mutating func lstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.startIndex
        while idx != self.endIndex && _set.contains(self[idx]) {
            idx = self.index(after: idx)
        }
        self = self[idx...]
    }

    mutating func rstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.endIndex
        while idx != self.startIndex
            && _set.contains(self[self.index(before: idx)])
        {
            idx = self.index(before: idx)
        }
        self = self[..<idx]
    }

    mutating func strip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        self.lstrip()
        self.rstrip()
    }
}

extension String {
    mutating func lstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.startIndex
        while idx != self.endIndex && _set.contains(self[idx]) {
            idx = self.index(after: idx)
        }
        self = String(self[idx...])
    }

    mutating func rstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.endIndex
        while idx != self.startIndex
            && _set.contains(self[self.index(before: idx)])
        {
            idx = self.index(before: idx)
        }
        self = String(self[..<idx])
    }

    mutating func strip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        self.lstrip()
        self.rstrip()
    }
}


extension Array where Element: Comparable {
    static func >(_ s1: [Element], _ s2: [Element]) -> Bool {
        let length = Swift.min(s1.count, s2.count)
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

    func minmax() -> (head: Element, tail: Element)? {
        if count == 0 {
            return nil
        }
        var s1 = self[0]
        var s2 = self[0]
        for i in 0..<count {
            if self[i] > s1 {
                s1 = self[i]
            } else if s2 > self[i] {
                s2 = self[i]
            }
        }
        return (s1, s2)
    }

}

extension Array where Element == [String.SubSequence] {
    func minmax() -> (head: [String.SubSequence], tail: [String.SubSequence])? {
        if count == 0 {
            return nil
        }
        var s1 = self[0]
        var s2 = self[0]
        for i in 0..<count {
            if self[i] > s1 {
                s1 = self[i]
            } else if s2 > self[i] {
                s2 = self[i]
            }
        }
        return (s1, s2)
    }
}