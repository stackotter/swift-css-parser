/// An indentation style.
public enum IndentationStyle {
    case tabs
    case spaces(Int)

    /// The string representation of a single indent using this style.
    public var string: String {
        switch self {
            case .tabs:
                return "\t"
            case .spaces(let count):
                return String(repeating: " ", count: count)
        }
    }
}
