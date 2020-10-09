import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(PosixPathTests.allTests),
            testCase(ObjectPosixPathTests.allTests),
            testCase(NTPathTests.allTests),
            testCase(ObjectNTPathTests.allTests),
            testCase(OSTests.allTests),
            testCase(OSPathTests.allTests),
            testCase(ZFilesTests.allTests),
        ]
    }
#endif
