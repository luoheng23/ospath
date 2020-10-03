import Foundation

class OS {

    static func symlink(_ dst: String, _ at: String) throws {
        try Path.fileManager.createSymbolicLink(atPath: at, withDestinationPath: dst)
    }

    static func symlink(_ dst: URL, _ at: URL) throws {
        try Path.fileManager.createSymbolicLink(at: at, withDestinationURL: dst)
    }

    static func remove(_ file: String) throws {
        try Path.fileManager.removeItem(atPath: file)
    }

    static func remove(_ file: URL) throws {
        try Path.fileManager.removeItem(at: file)
    }

    static func open(_ file: String) -> Bool {
        return Path.fileManager.createFile(atPath: file, contents: nil)
    }
}