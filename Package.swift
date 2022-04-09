// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "swift-css-parser",
    products: [
        .library(
            name: "SwiftCSSParser",
            targets: ["SwiftCSSParser"]
        ),
    ],
    dependencies: [],
    targets: [
        // A Swift wrapper for the C wrapper
        .target(
            name: "SwiftCSSParser",
            dependencies: [
                "CCSSParser"
            ]
        ),

        // A C wrapper for the CPP CSS parser
        .target(
            name: "CCSSParser",
            dependencies: [
                "CSSParser"
            ],
            publicHeadersPath: "."
        ),

        // The CPP CSS parser
        .target(
            name: "CSSParser",
            path: "cssparser/cssparser",
            exclude: ["main.cpp"],
            publicHeadersPath: "."
        ),

        .testTarget(
            name: "CSSParserTests",
            dependencies: [
                "SwiftCSSParser"
            ]
        ),
    ]
)
