import Foundation
import CCSSParser
import Metal

/// An error which occurs during parsing. See ``Stylesheet/parse(from:)``.
public struct ParsingError: LocalizedError {
    /// The error message.
    public var message: String

    public var errorDescription: String? {
        message
    }
}

/// A straight translation of the underlying cssparser token type (from cpp).
public struct Token {
    /// The type of token
    public var type: TokenType
    /// Any textual data associated with this token.
    public var data: String
}

/// A type of token. See ``Token``.
public enum TokenType: Int, Equatable {
    case charset
    case importDeclaration
    case namespace
    case atStart
    case atEnd
    case selectorStart
    case selectorEnd
    case property
    case value
    case comment
    case cssEnd
}

/// An at-block, e.g. an `@media` css block.
public struct AtBlock: Equatable {
    /// The block's identifier (e.g. for an `@media` it's `media`).
    public var identifier: String
    /// The statements nested inside the block.
    public var statements: [Statement]

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this at-block.
    public func minified() -> String {
        let content = statements.map { statement in
            statement.minified()
        }.joined(separator: "")
        return "@\(identifier){\(content)}"
    }
}

/// A set of ``Declaration``s that apply to a specific selector.
public struct RuleSet: Equatable {
    /// The selector that this set of declarations applies to.
    public var selector: String
    /// The rule set's declarations.
    public var declarations: [Declaration]

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this at-block.
    public func minified() -> String {
        var output = selector + "{"
        for i in 0..<declarations.count {
            let declaration = declarations[i]
            output += declaration.property + ":" + declaration.value
            if i != declarations.count - 1 {
                output += ";"
            }
        }
        output += "}"
        return output
    }
}

/// A declaration inside a ``RuleSet``.
public struct Declaration: Equatable {
    /// The property that this declaration is for.
    public var property: String
    /// The value this declaration sets for the property.
    public var value: String
}

/// A CSS statement.
public enum Statement: Equatable {
    case charsetRule(String)
    case importRule(String)
    case namespaceRule(String)
    case atBlock(AtBlock)
    case ruleSet(RuleSet)

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this at-block.
    public func minified() -> String {
        switch self {
            case .charsetRule(let string):
                return "@charset \(string);"
            case .importRule(let string):
                return "@import \(string);"
            case .namespaceRule(let string):
                return "@namespace \(string);"
            case .atBlock(let block):
                return block.minified()
            case .ruleSet(let ruleSet):
                return ruleSet.minified()
        }
    }

    public func prettyPrinted() -> String {
        ""
    }
}

/// A CSS stylesheet.
public struct Stylesheet: Equatable {
    /// The stylesheet's tokens.
    public var statements: [Statement]

    /// Creates a stylesheet from a list of statements. Does not verify that the list of statements is strictly valid CSS.
    /// - Parameter statements: The sheet's stataements.
    public init(_ statements: [Statement]) {
        self.statements = statements
    }

    /// Parses a CSS document from a string.
    /// - Parameter string: The string to parse.
    /// - Returns: The parsed stylesheet.
    /// - Throws: A ``ParsingError`` if parsing fails.
    public static func parse(from string: String) throws -> Stylesheet {
        // Create parser and remember to destroy it when finished
        let parser = css_parser_create()
        defer {
            css_parser_destroy(parser)
        }

        // Parse
        css_parser_set_level(parser, "CSS3.0")
        css_parser_parse_css(parser, string)

        // Check for errors
        if let errorCString = css_parser_get_error(parser) {
            throw ParsingError(message: String(cString: errorCString))
        }

        // Convert tokens to Swift types
        var cTokens: [Token] = []
        while true {
            let cToken = css_parser_get_next_token(parser)
            guard let tokenType = TokenType(rawValue: Int(cToken.type.rawValue)) else {
                throw ParsingError(message: "Invalid token type: \(cToken.type.rawValue)")
            }

            let data = String(cString: cToken.data)
            css_token_free(cToken)

            if tokenType == .cssEnd {
                break
            }

            cTokens.append(Token(type: tokenType, data: data))
        }

        // Parse tokens into statements
        var iterator = cTokens.makeIterator()
        let statements = try parseStatements(from: &iterator)

        // Ensure that the entire iterator has been consumed
        guard iterator.next() == nil else {
            var count = 1
            while iterator.next() != nil {
                count += 1
            }
            throw ParsingError(message: "Failed to parse document, \(count) tokens remained after parsing")
        }

        return Stylesheet(statements)
    }

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this at-block.
    public func minified() -> String {
        return statements.map { statement in
            statement.minified()
        }.joined(separator: "")
    }

    public static func parseStatements<Iterator: IteratorProtocol>(
        from tokens: inout Iterator
    ) throws -> [Statement] where Iterator.Element == Token {
        var statements: [Statement] = []

    loop:
        while let token = tokens.next() {
            let content = token.data
            switch token.type {
                case .charset:
                    statements.append(.charsetRule(content))
                case .importDeclaration:
                    statements.append(.importRule(content))
                case .namespace:
                    statements.append(.namespaceRule(content))

                case .atStart:
                    // The leading @ symbol must be removed
                    let identifier = String(content.dropFirst())
                    let childStatements = try parseStatements(from: &tokens)
                    statements.append(.atBlock(AtBlock(
                        identifier: identifier,
                        statements: childStatements)
                    ))
                case .atEnd:
                    break loop

                case .selectorStart:
                    let selector = content
                    let declarations = try parseDeclarations(from: &tokens)
                    statements.append(.ruleSet(RuleSet(
                        selector: selector,
                        declarations: declarations)
                    ))
                case .selectorEnd:
                    throw ParsingError(message: "selectorEnd token found outside of a selector block")

                // If either property or value is reached through these cases, they are not inside a block and are therefore ignored
                case .property:
                    continue loop
                case .value:
                    continue loop

                case .comment:
                    // Comments are not statements
                    continue loop

                case .cssEnd:
                    break loop
            }
        }
        return statements
    }

    static func parseDeclarations<Iterator: IteratorProtocol>(
        from tokens: inout Iterator
    ) throws -> [Declaration] where Iterator.Element == Token {
        var declarations: [Declaration] = []
        while true {
            // Get the property (skipping comments)
            var propertyToken = tokens.next()
            while propertyToken?.type == .comment {
                propertyToken = tokens.next()
            }

            guard let propertyToken = propertyToken else {
                throw ParsingError(message: "Expected property, got end of token stream")
            }

            if propertyToken.type == .selectorEnd {
                // The end of the ruleset has been reached
                break
            }

            guard propertyToken.type == .property else {
                throw ParsingError(message: "Expected property, got \(propertyToken.type)")
            }

            // Get the value (skipping comments)
            var valueToken = tokens.next()
            while valueToken?.type == .comment {
                valueToken = tokens.next()
            }

            guard let valueToken = valueToken else {
                throw ParsingError(message: "Expected value, got end of token stream")
            }

            guard valueToken.type == .value else {
                throw ParsingError(message: "Expected value to follow property, but got \(valueToken.type)")
            }

            declarations.append(Declaration(property: propertyToken.data, value: valueToken.data))
        }
        return declarations
    }
}
