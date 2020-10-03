
import Foundation

internal class Path {

    static let fileManager = FileManager.default

    // if given string is not found, return startIndex

    // split a path in root and extension
    // The extension is everything starting at the last dot in the last
    // pathname component; the root is everything before that.
    // It is always true that root + ext == p.
    static func splitext(path: String, sep: String, altsep: String?, extsep: String) -> (String, String) {
        var sepIndex: String.Index
        var sepIndexValid = true
        if let pos = path.lastIndex(where: { $0 == sep.first }) {
            sepIndex = pos
        } else {
            sepIndex = path.startIndex
            sepIndexValid = false
        }
        if let alt = altsep {
            if let pos = path[sepIndex...].lastIndex(where: { $0 == alt.first }) {
                sepIndex = pos
                sepIndexValid = true
            }
        }

        if let pos = path[sepIndex...].lastIndex(where: { $0 == extsep.first }) {
            // skip all leading dots
            var filenameIndex = sepIndexValid ? path.index(after: sepIndex) : path.startIndex
            while filenameIndex != pos {
                if path[filenameIndex] != extsep.first {
                    return (String(path[..<pos]), String(path[pos...]))
                }
                filenameIndex = path.index(after: filenameIndex)
            }
        }
        return (path, "")
    }
}