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

extension Array where Element: Comparable {
    static func > (_ s1: [Element], _ s2: [Element]) -> Bool {
        let length = Swift.min(s1.count, s2.count)
        for i in 0..<length {
            if s1[i] > s2[i] {
                return true
            }
            if s1[i] < s2[i] {
                return false
            }
        }
        return false
    }

    func minmax() -> (head: Element, tail: Element)? {
        if count == 0 {
            return nil
        }
        var s1 = self[0]
        var s2 = self[0]
        for i in 0..<count {
            if self[i] > s1 {
                s1 = self[i]
            }
            else if s2 > self[i] {
                s2 = self[i]
            }
        }
        return (s1, s2)
    }

}

extension Array where Element == [String.SubSequence] {
    func minmax() -> (head: [String.SubSequence], tail: [String.SubSequence])? {
        if count == 0 {
            return nil
        }
        var s1 = self[0]
        var s2 = self[0]
        for i in 0..<count {
            if self[i] > s1 {
                s1 = self[i]
            }
            else if s2 > self[i] {
                s2 = self[i]
            }
        }
        return (s1, s2)
    }
}
