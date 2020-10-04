import Foundation

internal class Path {

    static let fileManager = FileManager.default

    // if given string is not found, return startIndex

    // split a path in root and extension
    // The extension is everything starting at the last dot in the last
    // pathname component; the root is everything before that.
    // It is always true that root + ext == p.
    static func splitext(
        path: String,
        sep: String,
        altsep: String?,
        extsep: String
    ) -> (
        String, String
    ) {
        var sepIndex: String.Index
        var sepIndexValid = true
        if let pos = path.lastIndex(where: { $0 == sep.first }) {
            sepIndex = pos
        }
        else {
            sepIndex = path.startIndex
            sepIndexValid = false
        }
        if let alt = altsep {
            if let pos = path[sepIndex...].lastIndex(where: { $0 == alt.first })
            {
                sepIndex = pos
                sepIndexValid = true
            }
        }

        if let pos = path[sepIndex...].lastIndex(where: { $0 == extsep.first })
        {
            // skip all leading dots
            var filenameIndex =
                sepIndexValid ? path.index(after: sepIndex) : path.startIndex
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

extension String.SubSequence {
    mutating func lstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.startIndex
        while idx != self.endIndex && _set.contains(self[idx]) {
            idx = self.index(after: idx)
        }
        self = self[idx...]
    }

    mutating func rstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.endIndex
        while idx != self.startIndex
            && _set.contains(self[self.index(before: idx)])
        {
            idx = self.index(before: idx)
        }
        self = self[..<idx]
    }

    mutating func strip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        self.lstrip()
        self.rstrip()
    }
}

extension String {
    mutating func lstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.startIndex
        while idx != self.endIndex && _set.contains(self[idx]) {
            idx = self.index(after: idx)
        }
        self = String(self[idx...])
    }

    mutating func rstrip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        var idx = self.endIndex
        while idx != self.startIndex
            && _set.contains(self[self.index(before: idx)])
        {
            idx = self.index(before: idx)
        }
        self = String(self[..<idx])
    }

    mutating func strip(_ _set: Set<Character> = []) {
        guard !_set.isEmpty else { return }
        self.lstrip()
        self.rstrip()
    }
}
