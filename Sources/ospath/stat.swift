public class StatResult {
    public var st_mode: Int = -1
    public var st_ino: Int = -1
    public var st_dev: Int = -1
    public var st_nlink: Int = -1
    public var st_uid: Int = -1
    public var st_gid: Int = -1
    public var st_size: Int = -1
    public var st_atime: Double = -1
    public var st_mtime: Double = -1
    public var st_ctime: Double = -1
}

extension StatResult: CustomStringConvertible {
    public var description: String {
        var str = ""
        str +=
            "st_mode=\(st_mode), st_ino=\(st_ino), st_dev=\(st_dev), st_nlink=\(st_nlink), st_uid=\(st_uid), st_gid=\(st_gid), st_size=\(st_size), st_ctime=\(st_ctime), "
        str += "st_atime=\(st_atime), st_mtime=\(st_mtime)"
        str = "StatResult(\(str))"
        return str
    }
}

