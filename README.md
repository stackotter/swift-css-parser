# SwiftCSSParser

A lightweight CSS parser for Swift that uses [cssparser](https://github.com/Sigil-Ebook/cssparser.git) (cpp) under the hood.

## Basic usage

Here's a simple code snippet to get you started.

```swift
// An example stylesheet (with horrible formatting)
let css = """
div { background: blue
  }
"""

// Parse the stylesheet
let stylesheet = try Stylesheet.parse(css)

// Minify
assert(
  stylesheet.minified())
    ==
  "div{color:blue}"
)

// Pretty print
assert(
  stylesheet.prettyPrinted(with: .spaces(2))
    ==
  """
  div {
    color: blue;
  }
  """
)

// Extract property
var background: String?
for statement in stylesheet.statements {
  switch statement {
    case .ruleSet(let ruleSet):
      for declaration in ruleSet.declarations where declaration.property == "background" {
        background = declaration.value
        break
      }
    default:
      break
  }
}

assert(
  background
    ==
  "blue"
)
```

## Statements

The main CSS parsing API is built on the concept of CSS statements. It is the easiest to use and most type-safe API that SwiftCSSParser offers for parsing and creating CSS documents. However, the main limitation of the statements API is that it does not handle comments, it also may just ignore tokens that it deems to be invalid. If you find any cases where the statements generated from a document incorrectly ignore a valid token, open an issue.

To parse a document into statements, use the `Stylesheet.parseStatements(from:)` method. This is equivalent to `Stylesheet.parse(from: css).statements`.

## Tokens

The tokens based API is a lower level and more simplistic version of the statements API. It is a direct Swift translation of the parsing aspect of the `cssparser` API.

To parse a document into tokens, use the `Stylesheet.parseTokens(from:)` method. The resulting token stream includes comments.

## Contributing

```sh
# 1. Fork swift-css-parser
# 2. Clone your fork
git clone https://github.com/yourusername/swift-css-parser 

# 3. Finish cloning the repository
cd swift-css-parser
git submodule update --init --recursive
```
