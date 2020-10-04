#if os(Windows)
    public typealias OSPath = PosixPath
#else
    public typealias OSPath = NTPath
#endif
