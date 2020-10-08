import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(PosixPathTests.allTests),
            testCase(NTPathTests.allTests),
            testCase(OSTests.allTests),
            testCase(OSPathTests.allTests),
            testCase(ZFilesTests.allTests),
        ]
    }
#endif
