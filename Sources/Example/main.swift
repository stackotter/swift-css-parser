import SwiftCSSParser

let basicCSS = """
div {
    color: blue;
}
"""

do {
    _ = try Stylesheet.parse(from: basicCSS)
} catch {
    print(error)
}

