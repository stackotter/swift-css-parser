/// A set of ``Declaration``s that apply to a specific selector.
public struct RuleSet: Equatable {
    /// The selector that this set of declarations applies to.
    public var selector: String
    /// The rule set's declarations.
    public var declarations: [Declaration]

    /// Creates a rule set.
    /// - Parameters:
    ///   - selector: The selector that this rule set applies to.
    ///   - declarations: The declarations that the rule set applies.
    public init(selector: String, declarations: [Declaration]) {
        self.selector = selector
        self.declarations = declarations
    }

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this rule set.
    public func minified() -> String {
        let content = declarations.map { declaration in
            declaration.minified()
        }.joined(separator: ";")

        var output = selector + "{"
        output += content
        output += "}"
        return output
    }

    /// Gets a nicely formatted string representation of this rule set.
    /// - Parameter indentation: The style of indentation to use.
    /// - Returns: A nicely formatted string representation of this rule set.
    public func prettyPrinted(with indentation: IndentationStyle) -> String {
        let content = declarations.map { declaration in
            indentation.string + declaration.prettyPrinted(with: indentation)
        }.joined(separator: "\n")

        var output = selector + " {\n"
        output += content
        output += "\n}"
        return output
    }
}
