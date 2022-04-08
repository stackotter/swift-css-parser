import Foundation
import CCSSParser

/// An error which occurs during parsing. See ``Stylesheet/parse(from:)``.
public struct ParsingError: LocalizedError {
    /// The error message.
    public var message: String

    public var errorDescription: String? {
        message
    }
}

/// A type of token. See ``Token``.
public enum TokenType: Int {
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

/// A token within a CSS stylesheet.
public struct Token {
    /// The token's type.
    public var type: TokenType
    /// The token's associated data.
    public var data: String

    /// Creates a new token.
    /// - Parameters:
    ///   - type: The token's type.
    ///   - data: The token's associated data.
    public init(type: TokenType, data: String) {
        self.type = type
        self.data = data
    }

    /// Creates a token from a c representation of the token.
    /// - Parameter cToken: The c representation of the token.
    public init?(_ cToken: CToken) {
        guard let type = TokenType(rawValue: Int(cToken.type.rawValue)) else {
            return nil
        }
        self.type = type
        self.data = String(cString: cToken.data)
    }
}

/// A CSS stylesheet.
public struct Stylesheet {
    /// The stylesheet's tokens.
    public var tokens: [Token]

    /// Creates a stylesheet from a list of tokens. Does not verify that the list of tokens is valid.
    /// - Parameter tokens: The sheet's tokens.
    public init(_ tokens: [Token]) {
        self.tokens = tokens
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
        var tokens: [Token] = []
        while let token = Token(css_parser_get_next_token(parser)), token.type != .cssEnd {
            tokens.append(token)
        }

        return Stylesheet(tokens)
    }

    /// Creates a minified representation of the stylesheet.
    /// - Returns: A minified CSS string.
    public func minify() -> String {
        var minified = ""
        for i in 0..<tokens.count {
            let token = tokens[i]
            let next = (i + 1 < tokens.count) ? tokens[i + 1] : nil

            switch token.type {
                case .charset:
                    minified += "@charset \(token.data);"
                case .importDeclaration:
                    minified += "@import \(token.data);"
                case .namespace:
                    minified += "@namespace \(token.data);"
                case .atStart:
                    minified += token.data + "{"
                case .atEnd:
                    minified += "}"
                case .selectorStart:
                    minified += token.data + "{"
                case .selectorEnd:
                    minified += "}"
                case .property:
                    minified += token.data + ":"
                case .value:
                    minified += token.data
                    if next?.type == .property {
                        minified += ";"
                    }
                case .comment:
                    continue
                case .cssEnd:
                    break
            }
        }

        return minified
    }
}
