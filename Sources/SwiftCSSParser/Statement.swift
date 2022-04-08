/// A CSS statement.
public enum Statement: Equatable {
    case charsetRule(String)
    case importRule(String)
    case namespaceRule(String)
    case atBlock(AtBlock)
    case ruleSet(RuleSet)

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this statement.
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

    /// Gets a nicely formatted string representation of this statement.
    /// - Parameter indentation: The style of indentation to use.
    /// - Returns: A nicely formatted string representation of this statement.
    public func prettyPrinted(with indentation: IndentationStyle) -> String {
        switch self {
            case .charsetRule(let string):
                return "@charset \(string);"
            case .importRule(let string):
                return "@import \(string);"
            case .namespaceRule(let string):
                return "@namespace \(string);"
            case .atBlock(let block):
                return block.prettyPrinted(with: indentation)
            case .ruleSet(let ruleSet):
                return ruleSet.prettyPrinted(with: indentation)
        }
    }
}
