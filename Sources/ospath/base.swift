
import Foundation

public class BasePath {
    static let curdir = "."
    static let pardir = ".."
    static let extsep = "."
 
    class var sep: String {
        return "/"  // posix path
    }

    class var pathsep: String {
        return ":"
    }

    class var funcpath: String {
        return "/bin:/usr/bin"
    }

    class var altsep: String? {
        return nil
    }

    class var devnull: String {
        return "/dev/null"
    }
}

extension BasePath {

    public class func normcase(_ path: String) -> String {
        return path
    }

    // check if path is absolute
    public class func isabs(_ path: String) -> Bool {
        return path.hasPrefix(String(sep))
    }

    // join pathnames
    public class func join(_ basePath: String, _ toJoinedPaths: String...) -> String {
        var path = basePath
        for p in toJoinedPaths {
            if isabs(p) {
                // the path is an absolute path
                path = p
            } else if path == "" || path.hasSuffix(sep) {
                path += p
            } else {
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
        } else {
            lastIndex = path.startIndex
        }

        var (head, tail) = (path[..<lastIndex], path[lastIndex...])

        if !head.allSatisfy({ $0 == sep.first }) {
            var i = head.endIndex
            while i != head.startIndex {
                i = head.index(i, offsetBy: -1)
                if head[i] != sep.first {
                    break
                }
            }
            head = head[...i]
        }
        return (String(head), String(tail))
    }

    public class func splitdrive(_ path: String) -> (head: String, tail: String) {
        return ("", path)
    }

    public class func basename(_ path: String) -> String {
        let (_, name) = split(path)
        return name
    }

    public class func dirname(_ path: String) -> String {
        let (name, _) = split(path)
        return name
    }

    public class func islink(_ path: String) -> Bool {
        do {

            let _ = try Path.fileManager.attributesOfItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    public class func lexists(_ path: String) -> Bool {
        do {
            let _ = try Path.fileManager.destinationOfSymbolicLink(atPath: path)
            return true
        } catch {
            return false
        }
    }
}