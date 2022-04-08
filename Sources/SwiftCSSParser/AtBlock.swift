/// An at-block, e.g. an `@media` css block.
public struct AtBlock: Equatable {
    /// The block's identifier (e.g. for an `@media` it's `media`).
    public var identifier: String
    /// The statements nested inside the block.
    public var statements: [Statement]

    /// Gets a string representation of this at-block with the minimum possible length.
    /// - Returns: A minified string representation of this at-block.
    public func minified() -> String {
        let content = statements.map { statement in
            statement.minified()
        }.joined(separator: "")
        return "@\(identifier){\(content)}"
    }

    /// Gets a nicely formatted string representation of this at-block.
    /// - Parameter indentation: The style of indentation to use.
    /// - Returns: A nicely formatted string representation of this at-block.
    public func prettyPrinted(with indentation: IndentationStyle) -> String {
        let content = statements.map { statement in
            statement
                .prettyPrinted(with: indentation)
                .indent(by: 1, with: indentation)
        }.joined(separator: "\n\n")

        var output = "@\(identifier) {\n"
        output += content
        output += "\n}"
        return output
    }
}
