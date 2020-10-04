import Foundation

public class OS {

  public static func symlink(_ dst: String, _ at: String) throws {
    try Path.fileManager.createSymbolicLink(atPath: at, withDestinationPath: dst)
  }

  public static func symlink(_ dst: URL, _ at: URL) throws {
    try Path.fileManager.createSymbolicLink(at: at, withDestinationURL: dst)
  }

  public static func link(_ at: String, _ dst: String) throws {
    try Path.fileManager.linkItem(atPath: at, toPath: dst)
  }

  public static func link(_ at: URL, _ dst: URL) throws {
    try Path.fileManager.linkItem(at: at, to: dst)
  }

  public static func readlink(_ link: String) -> String {
    return (try? Path.fileManager.destinationOfSymbolicLink(atPath: link)) ?? ""
  }

  public static func remove(_ file: String) throws {
    try Path.fileManager.removeItem(atPath: file)
  }

  public static func remove(_ file: URL) throws {
    try Path.fileManager.removeItem(at: file)
  }

  public static func copy(_ file: String, _ dst: String) throws {
    try Path.fileManager.copyItem(atPath: file, toPath: dst)
  }

  public static func copy(_ file: URL, _ dst: URL) throws {
    try Path.fileManager.copyItem(at: file, to: dst)
  }

  public static func move(_ file: String, _ dst: String) throws {
    try Path.fileManager.moveItem(atPath: file, toPath: dst)
  }

  public static func move(_ file: URL, _ dst: URL) throws {
    try Path.fileManager.moveItem(at: file, to: dst)
  }

  public static func open(_ file: String) -> Bool {
    return Path.fileManager.createFile(atPath: file, contents: nil)
  }

  public static func mkdir(_ dir: String) throws {
    try Path.fileManager.createDirectory(atPath: dir, withIntermediateDirectories: false)
  }

  public static func mkdir(_ dir: URL) throws {
    try Path.fileManager.createDirectory(at: dir, withIntermediateDirectories: false)
  }

  public static func makedirs(_ dir: String) throws {
    try Path.fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true)
  }

  public static func makedirs(_ dir: URL) throws {
    try Path.fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
  }
}

extension OS {

  public static func stat(_ path: String) throws -> StatResult {
    do {
      let attrs = try Path.fileManager.attributesOfItem(atPath: path)
      let stat = StatResult()
      stat.st_mode = attrs[.posixPermissions] as? Int ?? -1
      stat.st_ino = attrs[.systemFileNumber] as? Int ?? -1
      stat.st_dev = attrs[.deviceIdentifier] as? Int ?? -1
      stat.st_nlink = attrs[.referenceCount] as? Int ?? -1
      stat.st_uid = attrs[.ownerAccountID] as? Int ?? -1
      stat.st_gid = attrs[.groupOwnerAccountID] as? Int ?? -1
      stat.st_size = attrs[.size] as? Int ?? -1
      stat.st_mtime = (attrs[.modificationDate] as? Date)?.timeIntervalSince1970 ?? -1
      stat.st_ctime = (attrs[.creationDate] as? Date)?.timeIntervalSince1970 ?? -1
      // TODO Find a way to get the access time
      stat.st_atime = -1
      return stat
    } catch {
      return StatResult()
    }
  }
}

extension OS {
  public static func getcwd() -> String {
    return Path.fileManager.currentDirectoryPath
  }

  public static func home(_ user: String = "") -> String? {
    if user != "" {
      if #available(macOS 10.12, *) {
        if let p = Path.fileManager.homeDirectory(forUser: user) {
          return p.path
        } else {
          return nil
        }
      } else {
        return NSHomeDirectoryForUser(user)
      }
    }
    return ProcessInfo.processInfo.environment["HOME"]
  }
}
