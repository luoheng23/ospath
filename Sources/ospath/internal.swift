
import Foundation

internal class Path {

    static let fileManager = FileManager.default

    // if given string is not found, return startIndex
    static func rIndexOf(_ path: String, _ sep: String) -> String.Index  {
        let pos = path.lastIndex(where: { $0 == sep.first })
        if let p = pos {
            return path.index(after: p)
        }
        return path.startIndex
    }


}