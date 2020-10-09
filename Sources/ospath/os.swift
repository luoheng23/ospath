import Foundation

public class OS {

    public static func symlink(_ dst: String, _ at: String) throws {
        try Path.fileManager.createSymbolicLink(
            atPath: at,
            withDestinationPath: dst
        )
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
        return (try? Path.fileManager.destinationOfSymbolicLink(atPath: link))
            ?? ""
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
        do {
            try Path.fileManager.createDirectory(
                atPath: dir,
                withIntermediateDirectories: true
            )
        }
        catch {
            throw WriteError(path: dir, reason: .folderCreationFailed(error))
        }
    }

    public static func mkdir(_ dir: URL) throws {
        do {
            try Path.fileManager.createDirectory(
                at: dir,
                withIntermediateDirectories: false
            )
        }
        catch {
            throw WriteError(
                path: dir.path,
                reason: .folderCreationFailed(error)
            )
        }
    }

    public static func makedirs(_ dir: String) throws {
        do {
            try Path.fileManager.createDirectory(
                atPath: dir,
                withIntermediateDirectories: true
            )
        }
        catch {
            throw WriteError(path: dir, reason: .folderCreationFailed(error))
        }
    }

    public static func makedirs(_ dir: URL) throws {
        do {
            try Path.fileManager.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
        }
        catch {
            throw WriteError(
                path: dir.path,
                reason: .folderCreationFailed(error)
            )
        }
    }
}

extension OS {

    static var environ = ProcessInfo.processInfo.environment

    // Get the status of a file, always follow links
    public static func stat(_ path: String, _ followSymlinks: Bool = true)
        throws -> StatResult
    {
        if followSymlinks && OSPath.islink(path) {
            return StatResult(at: OS.readlink(path))
        }
        return StatResult(at: path)
    }

    // Get the status of a file, never follow link
    public static func lstat(_ path: String) throws -> StatResult {
        return try OS.stat(path, false)
    }
}

extension OS {
    public static func getcwd() -> String {
        return Path.fileManager.currentDirectoryPath
    }

    public static func home(_ user: String = "") -> String? {
        if user != "" {
            if #available(macOS 10.12, *) {
                return Path.fileManager.homeDirectory(forUser: user)?.path
            }
            else {
                return NSHomeDirectoryForUser(user)
            }
        }
        return ProcessInfo.processInfo.environment["HOME"]
    }
}
