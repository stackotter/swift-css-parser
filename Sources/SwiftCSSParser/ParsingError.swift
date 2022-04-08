import Foundation

/// An error which occurs during parsing. See ``Stylesheet/parse(from:)``.
public struct ParsingError: LocalizedError {
    /// The error message.
    public var message: String

    public var errorDescription: String? {
        message
    }
}
