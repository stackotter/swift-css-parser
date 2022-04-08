extension String {
    /// Indents a string by the given number of indents.
    /// - Parameters:
    ///   - count: The number of indents to indent by.
    ///   - indentation: The style of indentation to use.
    /// - Returns: The indented string.
    func indent(by count: Int, with indentation: IndentationStyle) -> String {
        let indent = indentation.string
        return indent + self.split(separator: "\n").joined(separator: "\n" + indent)
    }
}
