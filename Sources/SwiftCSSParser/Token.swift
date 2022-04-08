/// A straight translation of the underlying cssparser token type (from cpp).
public struct Token {
    /// The type of token
    public var type: TokenType
    /// Any textual data associated with this token.
    public var data: String
}
