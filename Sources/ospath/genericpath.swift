
import Files

class GenericPath {
    // static func exists(_ path: String) {
    //     let (dirname, basename) = BasePath.dirname(path), BasePath.basename(path)
    //     if let folder = try? Folder(path: dirname), (try? folder.file(basename)) != nil {
    //         return true
    //     }
    //     return false
    // }

    // static func isfile(_ path: String) {
    //     return File(path: path).isfile
    // }

    // if given string is not found, return startIndex
    static func rPosAfterGivenStr(_ path: String, _ sep: String) {
        let pos = path.lastIndex(where: { $0 == sep.first })
        if pos == nil {
            
        }
    }

}