import XCTest

@testable import ospath

// TODO
final class FileReaderWriterTests: XCTestCase {

    func testRead() {
        let path = "README.md"
        if let file = FileReader(path) {
            for line in file {
                print(line, line.count)
            }
        }
    }

    static var allTests = [
        ("testRead", testRead)
    ]
}
