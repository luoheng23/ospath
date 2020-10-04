import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(PosixPathTests.allTests),
      testCase(OSTests.allTests),
    ]
  }
#endif
