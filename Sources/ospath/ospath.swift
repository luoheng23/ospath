#if os(Windows)
    public typealias OSPath = NTPath
#else
    public typealias OSPath = PosixPath
#endif
