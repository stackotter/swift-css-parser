import XCTest
@testable import SwiftCSSParser

final class CSSParserTests: XCTestCase {
    static let basicCSS = """
div {
    color: blue;
}
"""

    static let invalidCSS = """
div {
    color: blue;
"""

    func testBasicParsing() {
        do {
            _ = try Stylesheet.parse(from: Self.basicCSS)
        } catch {
            XCTFail("Failed to parse basic stylesheet")
        }
    }

    func testInvalidParsing() {
        do {
            _ = try Stylesheet.parse(from: Self.invalidCSS)
            XCTFail("Invalid CSS parsed without errors")
        } catch {
            guard let error = error as? ParsingError else {
                XCTFail("Error thrown was not a ParsingError")
                return
            }
            XCTAssertEqual(error.message, "3: Unbalanced selector braces in style sheet")
        }
    }

    func testBasicMinify() {
        let stylesheet: Stylesheet
        do {
            stylesheet = try Stylesheet.parse(from: Self.basicCSS)
        } catch {
            XCTFail("Failed to load stylesheet for minification")
            return
        }

        XCTAssertEqual(stylesheet.minify(), "div{color:blue}")
    }
}
