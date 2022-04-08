import XCTest
@testable import SwiftCSSParser

final class CSSParserTests: XCTestCase {
    static let ruleSet = """
.markdown-body code,
.markdown-body kbd,
.markdown-body pre,
.markdown-body samp {
    font-family: monospace, monospace;
    font-size: 1em;
}
"""

    static let invalidCSS = """
div {
    color: blue;
"""

    static let nestedStatements = """
@charset "UTF-8";

    body {
background: red;
}

@media (max-width: 600px) { body {
        background: lightblue;}

    div {color: blue
    }
}
"""

    func testBasicParsing() throws {
        let stylesheet = try Stylesheet.parse(from: Self.ruleSet)

        XCTAssertEqual(
            stylesheet,
            Stylesheet([
                .ruleSet(RuleSet(
                    selector: ".markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp",
                    declarations: [
                        .init(property: "font-family", value: "monospace,monospace"),
                        .init(property: "font-size", value: "1em")
                    ]
                ))
            ])
        )
    }

    func testBasicMinify() throws {
        let stylesheet = try Stylesheet.parse(from: Self.ruleSet)

        XCTAssertEqual(
            stylesheet.minified(),
            ".markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp{font-family:monospace,monospace;font-size:1em}"
        )
    }

    func testBasicPrettyPrint() throws {
        let stylesheet = try Stylesheet.parse(from: Self.ruleSet)

        XCTAssertEqual(
            stylesheet.prettyPrinted(with: .spaces(2)),
            """
.markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp {
  font-family: monospace,monospace;
  font-size: 1em;
}
"""
        )
    }

    func testNestedStatementsPrettyPrint() throws {
        let stylesheet = try Stylesheet.parse(from: Self.nestedStatements)

        XCTAssertEqual(
            stylesheet.prettyPrinted(with: .spaces(4)),
            """
@charset UTF-8;

body {
    background: red;
}

@media (max-width: 600px) {
    body {
        background: lightblue;
    }

    div {
        color: blue;
    }
}
"""
        )
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
}
