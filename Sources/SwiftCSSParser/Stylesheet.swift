import Foundation
import CCSSParser

/// A parsed CSS stylesheet.
public struct Stylesheet: Equatable {
    /// The stylesheet's tokens.
    public var statements: [Statement]

    // MARK: Init

    /// Creates a stylesheet from a list of statements. Does not verify that the list of statements is strictly valid CSS.
    /// - Parameter statements: The sheet's stataements.
    public init(_ statements: [Statement]) {
        self.statements = statements
    }

    // MARK: Public methods

    /// Parses a CSS document.
    /// - Parameter string: The string to parse.
    /// - Returns: The parsed stylesheet.
    /// - Throws: A ``ParsingError`` if parsing fails.
    public static func parse(from string: String) throws -> Stylesheet {
        let statements = try Self.parseStatements(from: string)
        return Stylesheet(statements)
    }

    /// Parses a CSS document into statements. Statements are a higher level version of Tokens (see ``parseTokens(from:)``).
    /// - Parameter string: The string to parse.
    /// - Returns: The statements parsed from the document.
    /// - Throws: A ``ParsingError`` if parsing fails.
    public static func parseStatements(from string: String) throws -> [Statement] {
        let tokens = try parseTokens(from: string)

        // Parse tokens into statements
        var iterator = tokens.makeIterator()
        let statements = try parseStatements(from: &iterator)

        // Ensure that the entire iterator has been consumed
        guard iterator.next() == nil else {
            var count = 1
            while iterator.next() != nil {
                count += 1
            }
            throw ParsingError(message: "Failed to parse document, \(count) tokens remained after parsing")
        }

        return statements
    }

    /// Parses a CSS document into tokens. Tokens are a more low-level representation than statements, and the main difference other than structure is that comments are maintained.
    /// - Parameter string: The string to parse.
    /// - Returns: The tokens parsed from the document.
    /// - Throws: A ``ParsingError`` if parsing fails.
    public static func parseTokens(from string: String) throws -> [Token] {
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
        var tokens: [Token] = []
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

            tokens.append(Token(type: tokenType, data: data))
        }

        return tokens
    }

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this stylesheet.
    public func minified() -> String {
        return statements.map { statement in
            statement.minified()
        }.joined(separator: "")
    }

    /// Gets a nicely formatted string representation of this stylesheet.
    /// - Parameter indentation: The style of indentation to use.
    /// - Returns: A nicely formatted string representation of this stylesheet.
    public func prettyPrinted(with indentation: IndentationStyle) -> String {
        return statements.map { statement in
            statement.prettyPrinted(with: indentation)
        }.joined(separator: "\n\n")
    }

    // MARK: Private methods

    /// Converts a token stream into a list of statements.
    /// - Parameter tokens: The token stream to parse.
    /// - Returns: A list of statements.
    private static func parseStatements<Iterator: IteratorProtocol>(
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

    /// Parses a list of declarations from a stream of tokens. Stops when a token of type ``TokenType/selectorEnd`` is reached.
    /// - Parameter tokens: The token stream to parse declarations from.
    /// - Returns: A list of declarations.
    /// - Throws: A ``ParsingError`` if a token other than ``TokenType/property``, ``TokenType/value``, ``TokenType/comment`` or ``TokenType/selectorEnd`` is encountered, or if a property token wasn't followed by a property token (ignoring comments).
    private static func parseDeclarations<Iterator: IteratorProtocol>(
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
