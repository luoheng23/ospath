import Foundation

internal class Path {

    static let fileManager = FileManager.default
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
