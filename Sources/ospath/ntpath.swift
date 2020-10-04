import Foundation

public class NTPath: BasePath {
  override class var sep: String {
    return "\\"  // nt path
  }

  override class var pathsep: String {
    return ";"
  }

  override class var defpath: String {
    return ".;C:\\bin"
  }

  override class var altsep: String? {
    return "/"
  }

  override class var devnull: String {
    return "nul"
  }

  override public class func normcase(_ path: String) -> String {
    return path.replacingOccurrences(of: altsep!, with: sep)
  }

  // check if path is absolute
  override public class func isabs(_ path: String) -> Bool {
    var p = normcase(path)
    guard !p.hasPrefix("\\\\?\\") else { return true }
    p = splitdrive(p).tail
    return p.count > 0 && ["\\", "/"].contains(p.first)
  }

  // join pathnames
  override public class func join(_ basePath: String, _ toJoinedPaths: String...) -> String {
    var (d, path) = splitdrive(basePath)
    for p in toJoinedPaths {
      let (pDrive, pPath) = splitdrive(p)
      if !pPath.isEmpty && ["\\", "/"].contains(pPath.first) {
        if !pDrive.isEmpty || d.isEmpty {
          d = pDrive
        }
        path = pPath
        continue
      } else if !pDrive.isEmpty && pDrive != d {
        if pDrive.lowercased != d.lowercased {
          d = pDrive
          path = pPath
          continue
        }
        d = pDrive
      }
      if !path.isEmpty && !["\\", "/"].contains(path.last) {
        path = path + sep
      }
      path += pPath
    }
    if !path.isEmpty && !["\\", "/"].contains(path.first) && !d.isEmpty && d.last != ":" {
      return d + sep + path
    }
    return d + path
  }

  // split a path in head (everything up to the last '/') and tail (the rest)
  // if head is like usr////, remove tailed '/'
  override public class func split(_ path: String) -> (head: String, tail: String) {
    let (d, p) = splitdrive(path)
    var i = p.endIndex
    while i != p.startIndex && !["\\", "/"].contains(p[p.index(before: i)]) {
      i = p.index(before: i)
    }
    var (head, tail) = (p[..<i], p[i...])
    if !head.allSatisfy({ ["\\", "/"].contains($0) }) {
      while true {
        if let c = head.last {
          if ["\\", "/"].contains(c) {
            head.removeLast()
          } else {
            break
          }
        }
      }
    }
    return (String(d + head), String(tail))
  }

  override public class func splitdrive(_ path: String) -> (head: String, tail: String) {
    guard path.count >= 2 else { return ("", path) }
    let normp = normcase(path)
    if normp.hasPrefix(sep + sep) && !normp.hasPrefix(sep + sep + sep) {
      if let index = normp[normp.index(normp.startIndex, offsetBy: 2)...].firstIndex(where: {
        $0 == sep.first
      }) {
        if let index2 = normp[normp.index(after: index)...].firstIndex(where: { $0 == sep.first }) {
          if index2 == normp.index(after: index) {
            return ("", path)
          }
          return (String(path[..<index2]), String(path[index2...]))
        } else {
          return (path, "")
        }
      } else {
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
    let specialPrefixes = ["\\\\.\\", "\\\\?\\"]
    guard !path.hasPrefix(specialPrefixes[0]) && !path.hasPrefix(specialPrefixes[1]) else {
      return path
    }

    var p = normcase(path)
    var d: String
    (d, p) = splitdrive(p)

    if p.hasPrefix(sep) {
      d += sep
      while true {
        if let c = p.first {
          if c == sep.first {
            p.removeFirst()
          } else {
            break
          }
        } else {
          break
        }
      }
    }

    var comps = p.split(separator: sep.first!)
    var i = 0
    while i < comps.count {
      if comps[i] == "" || comps[i] == curdir {
        comps.remove(at: i)
      } else if comps[i] == pardir {
        if i > 0 && comps[i - 1] != pardir {
          comps.removeSubrange((i - 1)...i)
          i -= 1
        } else if i == 0 && d.last == sep.first! {
          comps.remove(at: i)
        } else {
          i += 1
        }
      } else {
        i += 1
      }
    }
    if d.isEmpty && comps.isEmpty {
      comps.append(curdir[...])
    }
    return d + comps.joined(separator: sep)
  }

  override public class func commonpath(_ paths: [String]) -> String {
    guard !paths.isEmpty else { return "" }
    guard paths.count != 1 else { return paths[0] }

    let driveSplit = paths.map { splitdrive(normpath($0).lowercased) }
    var splitPaths = driveSplit.map { $0.1.split(separator: sep.first!) }

    guard
      driveSplit.allSatisfy({ $0.1.hasPrefix(sep) })
        || driveSplit.allSatisfy({ !$0.1.hasPrefix(sep) })
    else { return "" }
    let sameDrive = driveSplit[0].0
    for d in driveSplit {
      if d.0 != sameDrive {
        return ""
      }
    }

    let (drive, path) = splitdrive(normcase(paths[0]))
    var common = path.split(separator: sep.first!)
    common = common.filter { $0 != curdir }
    splitPaths = splitPaths.map { $0.filter { $0 != curdir } }
    var s1 = splitPaths[0]
    var s2 = splitPaths[0]
    for c in splitPaths {
      if bigThan(c, s2) {
        s2 = c
      } else if bigThan(s1, c) {
        s1 = c
      }
    }
    let pre = path.hasPrefix(sep) ? drive + sep : drive
    for i in 0..<s1.count {
      if s1[i] != s2[i] {
        return pre + common[..<i].joined(separator: sep)
      }
    }
    return pre + common.joined(separator: sep)
  }
}
