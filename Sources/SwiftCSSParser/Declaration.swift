/// A declaration inside a ``RuleSet``.
public struct Declaration: Equatable {
    /// The property that this declaration is for.
    public var property: String
    /// The value this declaration sets for the property.
    public var value: String

    /// Gets a string representation with the minimum possible length.
    /// - Returns: A minified string representation of this declaration.
    public func minified() -> String {
        return "\(property):\(value)"
    }

    /// Gets a nicely formatted string representation of this declaration.
    /// - Parameter indentation: The style of indentation to use.
    /// - Returns: A nicely formatted string representation of this declaration.
    public func prettyPrinted(with indentation: IndentationStyle) -> String {
        return "\(property): \(value);"
    }
}
