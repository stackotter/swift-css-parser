// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-css-parser",
    products: [
        .library(
            name: "CSSParser",
            targets: ["CSSParser"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CSSParser",
            dependencies: []
        ),
        .testTarget(
            name: "CSSParserTests",
            dependencies: ["CSSParser"]
        ),
    ]
)
