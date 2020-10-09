import Foundation

public class StatResult {
    // File mode: file type and file mode bits (permissions)
    public var st_mode: Int?
    // the inode number on Unix, the file index on Windows
    public var st_ino: Int?
    // identifier of the device on which this file resides
    public var st_dev: Int?
    // number of hard links
    public var st_nlink: Int?
    // user identifier of the file owner
    public var st_uid: Int?
    // group identifier of the file owner
    public var st_gid: Int?
    // size of the file in bytes
    public var st_size: Int?
    // access time
    // TODO Find a way to get the access time
    public var st_atime: Double?
    // modification time
    public var st_mtime: Double?
    // creation time or metadata change time
    public var st_ctime: Double?
    // owner name
    public var st_owner: String?
    // group owner name
    public var st_groupOwner: String?
    // file type
    public var st_type: FileAttributeType

    convenience init(at path: String) {
        self.init()
        if let attrs = try? Path.fileManager.attributesOfItem(atPath: path) {
            st_mode = attrs[.posixPermissions] as? Int
            st_ino = attrs[.systemFileNumber] as? Int
            st_dev = attrs[.systemNumber] as? Int
            st_nlink = attrs[.referenceCount] as? Int
            st_uid = attrs[.ownerAccountID] as? Int
            st_gid = attrs[.groupOwnerAccountID] as? Int
            st_size = attrs[.size] as? Int
            st_type = (attrs[.type] as? FileAttributeType) ?? .typeUnknown
            st_owner = attrs[.ownerAccountName] as? String
            st_groupOwner = attrs[.groupOwnerAccountName] as? String
            st_mtime =
                (attrs[.modificationDate] as? Date)?.timeIntervalSince1970
            st_ctime =
                (attrs[.creationDate] as? Date)?.timeIntervalSince1970
        }
    }

    init() {
        st_mode = nil
        st_ino = nil
        st_dev = nil
        st_nlink = nil
        st_uid = nil
        st_gid = nil
        st_size = nil
        st_atime = nil
        st_mtime = nil
        st_ctime = nil
        st_owner = nil
        st_groupOwner = nil
        st_type = .typeUnknown
    }
}

extension StatResult: CustomStringConvertible {
    public var description: String {
        var str = ""
        if let s = st_mode {
            str += "st_mode=\(s)"
        }
        if let s = st_ino {
            str += ", st_ino=\(s)"
        }
        if let s = st_dev {
            str += ", st_dev=\(s)"
        }
        if let s = st_nlink {
            str += ", st_nlink=\(s)"
        }
        if let s = st_uid {
            str += ", st_uid=\(s)"
        }
        if let s = st_gid {
            str += ", st_gid=\(s)"
        }
        if let s = st_owner {
            str += ", st_owner=\(s)"
        }
        if let s = st_groupOwner {
            str += ", st_groupOwner=\(s)"
        }
        if let s = st_size {
            str += ", st_size=\(s)"
        }
        if let s = st_atime {
            str += ", st_atime=\(s)"
        }
        if let s = st_mtime {
            str += ", st_mtime=\(s)"
        }
        if let s = st_ctime {
            str += ", st_ctime=\(s)"
        }
        str = "StatResult(\(str))"
        return str
    }
}

extension StatResult {
    var isfile: Bool { st_type == .typeRegular }
    var isdir: Bool { st_type == .typeDirectory }
    var issocket: Bool { st_type == .typeSocket }
    var islink: Bool { st_type == .typeSymbolicLink }
    var isblock: Bool { st_type == .typeBlockSpecial }
    var ischaracter: Bool { st_type == .typeCharacterSpecial }
}

extension StatResult: Equatable {
    public static func ==(_ stat1: StatResult, _ stat2: StatResult) -> Bool {
        if let ino1 = stat1.st_ino, let ino2 = stat2.st_ino,
            let dev1 = stat1.st_dev, let dev2 = stat2.st_dev {
                return ino1 == ino2 && dev1 == dev2
            }
        return false
    }
}