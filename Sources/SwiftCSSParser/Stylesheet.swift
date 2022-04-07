import Foundation
import CCSSParser

public struct ParsingError: LocalizedError {
    public var message: String

    public var errorDescription: String? {
        message
    }
}

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

public struct Token {
    var type: TokenType
    var data: String

    public init(type: TokenType, data: String) {
        self.type = type
        self.data = data
    }

    public init?(_ cToken: CToken) {
        guard let type = TokenType(rawValue: Int(cToken.type.rawValue)) else {
            return nil
        }
        self.type = type
        self.data = String(cString: cToken.data)
    }
}

public struct Stylesheet {
    public var tokens: [Token]

    public static func parse(from string: String) throws -> Stylesheet {
        let parser = css_parser_create()
        defer {
            css_parser_destroy(parser)
        }

        css_parser_set_level(parser, "CSS3.0")
        css_parser_parse_css(parser, string)

        if let errorCString = css_parser_get_error(parser) {
            throw ParsingError(message: String(cString: errorCString))
        }

        var tokens: [Token] = []
        while let token = Token(css_parser_get_next_token(parser)), token.type != .cssEnd {
            tokens.append(token)
        }

        return Stylesheet(tokens: tokens)
    }

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
