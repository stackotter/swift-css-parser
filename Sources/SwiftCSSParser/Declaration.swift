/// A declaration inside a ``RuleSet``.
public struct Declaration: Equatable {
    /// The property that this declaration is for.
    public var property: String
    /// The value this declaration sets for the property.
    public var value: String

    /// Creates a declaration.
    /// - Parameters:
    ///   - property: The name of the property that the declaration is for.
    ///   - value: The value that the declaration specifies for the property.
    public init(property: String, value: String) {
        self.property = property
        self.value = value
    }

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
