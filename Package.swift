// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "LifeHash",
    platforms: [
        .iOS(.v17),
        .macCatalyst(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "LifeHash",
            targets: ["LifeHash"]),
        ],
    dependencies: [
        .package(url: "https://github.com/BlockchainCommons/bc-lifehash", from: "0.4.1"),
        .package(url: "https://github.com/nicklockwood/LRUCache.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LifeHash",
            dependencies: [
                "LRUCache",
                .product(name: "CLifeHash", package: "bc-lifehash")
            ])
        ]
)
