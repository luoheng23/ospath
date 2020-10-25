import Foundation

public class OS {

    public static func symlink<T: PathLike>(_ dst: T, _ at: T) throws {
        try Path.fileManager.createSymbolicLink(
            atPath: at.path,
            withDestinationPath: dst.path
        )
    }

    public static func link<T: PathLike>(_ at: T, _ dst: T) throws {
        try Path.fileManager.linkItem(atPath: at.path, toPath: dst.path)
    }

    public static func readlink<T: PathLike>(_ link: T) -> T {
        return T.init(
            (try? Path.fileManager.destinationOfSymbolicLink(atPath: link.path))
                ?? ""
        )
    }

    public static func remove<T: PathLike>(_ file: T) throws {
        try Path.fileManager.removeItem(atPath: file.path)
    }

    public static func copy<T: PathLike>(_ file: T, _ dst: T) throws {
        try Path.fileManager.copyItem(atPath: file.path, toPath: dst.path)
    }

    public static func move<T: PathLike>(_ file: T, _ dst: T) throws {
        try Path.fileManager.moveItem(atPath: file.path, toPath: dst.path)
    }

    public static func open<T: PathLike>(_ file: T) -> Bool {
        return Path.fileManager.createFile(atPath: file.path, contents: nil)
    }

    public static func mkdir<T: PathLike>(_ dir: T) throws {
        do {
            try Path.fileManager.createDirectory(
                atPath: dir.path,
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

    public static func makedirs<T: PathLike>(_ dir: T) throws {
        do {
            try Path.fileManager.createDirectory(
                atPath: dir.path,
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

    public static var environ = ProcessInfo.processInfo.environment

    // Get the status of a file, always follow links
    public static func stat<T: PathLike>(
        _ path: T,
        _ followSymlinks: Bool = true
    )
        throws -> StatResult
    {
        if followSymlinks && OSPath.islink(path.path) {
            return StatResult(at: OS.readlink(path.path))
        }
        return StatResult(at: path.path)
    }

    // Get the status of a file, never follow link
    public static func lstat<T: PathLike>(_ path: T) throws -> StatResult {
        return try OS.stat(path.path, false)
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


extension OS {
    
}