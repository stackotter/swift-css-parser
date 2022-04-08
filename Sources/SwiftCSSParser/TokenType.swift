/// A type of token. See ``Token``.
public enum TokenType: Int, Equatable {
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
