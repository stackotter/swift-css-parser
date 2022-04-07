import CCSSParser

public struct Stylesheet {
    public static func parse(from string: String) throws -> Stylesheet {
        var cString = string.utf8CString
        cString.withUnsafeMutableBufferPointer { pointer in
            CCSSParser.dumpCSS(pointer.baseAddress!)
        }
        return Stylesheet()
    }
}
