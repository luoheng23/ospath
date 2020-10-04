import XCTest

@testable import ospath

final class OSTests: XCTestCase {

  func testStat() {
    let path = "README.md"
    do {
      let _ = try OS.stat(path)
      // print(attr)
    } catch {

    }
  }

  static var allTests = [
    ("testStat", testStat)
  ]
}
