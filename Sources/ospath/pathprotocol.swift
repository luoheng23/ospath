
// everything that has a instance member named path is a PathLike object
public protocol PathLike {
    var path: String { get }
    init(_ path: String)
}

extension String: PathLike {
    public var path: String { return self }
    public init(_ path: String) {
        self = path
    }
}

extension String.SubSequence: PathLike {
    public var path: String { return String(self) }
    public init(_ path: SubSequence) {
        self = path
    }
}

// add operators for PathObject
public protocol PathObject: PathLike {
    static func join(_ basePath: String, _ toJoinedPaths: String...) -> String
}

public func +<T: PathObject, U: PathLike>(lhs: T, rhs: U) -> T {
    let tp = type(of: lhs)
    return tp.init(tp.join(lhs.path, rhs.path))
}

public func +=<T: PathObject, U: PathLike>(lhs: inout T, rhs: U) {
    let tp = type(of: lhs)
    lhs = tp.init(tp.join(lhs.path, rhs.path))
}
