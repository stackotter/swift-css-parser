import XCTest
@testable import SwiftCSSParser

final class CSSParserTests: XCTestCase {
    static let basicCSS = """
div {
    color: blue;
}
"""

    func testBasicParsing() throws {
        do {
            _ = try Stylesheet.parse(from: Self.basicCSS)
        } catch {
            XCTFail()
        }
    }
}
