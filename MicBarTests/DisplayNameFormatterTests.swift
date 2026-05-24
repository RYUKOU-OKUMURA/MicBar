import XCTest
@testable import MicBar

final class DisplayNameFormatterTests: XCTestCase {
    func testUniqueNamesUnchanged() {
        let result = DisplayNameFormatter.format(names: ["USB Audio", "AirPods Pro"])
        XCTAssertEqual(result, ["USB Audio", "AirPods Pro"])
    }

    func testTwoDuplicateNames() {
        let result = DisplayNameFormatter.format(names: ["USB Audio", "USB Audio"])
        XCTAssertEqual(result, ["USB Audio", "USB Audio 2"])
    }

    func testThreeDuplicateNames() {
        let result = DisplayNameFormatter.format(names: ["USB Audio", "USB Audio", "USB Audio"])
        XCTAssertEqual(result, ["USB Audio", "USB Audio 2", "USB Audio 3"])
    }

    func testEmptyArray() {
        let result = DisplayNameFormatter.format(names: [])
        XCTAssertEqual(result, [])
    }
}
