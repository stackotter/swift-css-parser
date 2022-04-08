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

    static let multilineSelector = """
.markdown-body code,
.markdown-body kbd,
.markdown-body pre,
.markdown-body samp {
    font-family: monospace, monospace;
    font-size: 1em;
}
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

    func testExpectedTokens() throws {
        let stylesheet = try Stylesheet.parse(from: Self.multilineSelector)

        XCTAssertEqual(
            stylesheet.tokens[0],
            Token(type: .selectorStart, data: ".markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp")
        )
        XCTAssertEqual(
            stylesheet.tokens[1],
            Token(type: .property, data: "font-family")
        )
        XCTAssertEqual(
            stylesheet.tokens[2],
            Token(type: .value, data: "monospace,monospace")
        )
        XCTAssertEqual(
            stylesheet.tokens[3],
            Token(type: .property, data: "font-size")
        )
        XCTAssertEqual(
            stylesheet.tokens[4],
            Token(type: .value, data: "1em")
        )
        XCTAssertEqual(
            stylesheet.tokens[5],
            Token(type: .selectorEnd, data: ".markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp")
        )
    }
}
